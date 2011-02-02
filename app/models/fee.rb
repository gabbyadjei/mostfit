class Fee
  include DataMapper::Resource
  
  PAYABLE = [:loan_applied_on, :loan_approved_on, :loan_disbursal_date, :loan_scheduled_first_payment_date, :loan_first_payment_date, :client_grt_pass_date, :client_date_joined, :loan_installment_dates, :policy_issue_date]
  FeeDue        = Struct.new(:applicable, :paid, :due)
  FeeApplicable = Struct.new(:loan_id, :client_id, :fees_applicable)
  property :id,            Serial
  property :name,          String, :nullable => false
  property :percentage,    Float
  property :amount,        Integer
  property :min_amount,    Integer
  property :max_amount,    Integer
  property :payable_on,    Enum.send('[]',*PAYABLE), :nullable => false

  has n, :loan_products, :through => Resource
  has n, :client_types, :through => Resource
  has n, :insurance_products, :through => Resource
  # anything else will have to be ruby code - sorry
  
  validates_with_method :amount_is_okay
  validates_with_method :min_lte_max
  
  def amount_is_okay
    return true if (amount or percentage)
    return [false, "Either an amount or a percentage must be specified"]
  end

  def min_lte_max
    return true if (min_amount and max_amount and min_amount <= max_amount) or (min_amount.nil? or max_amount.nil?)
    return [false, "Minimum amount must be less than maximum amount"]
  end

  def description
    desc =  "#{name}: "
    desc += "#{percentage*100} %" if percentage and percentage>0
    desc += " Amount Rs. #{amount}" if amount
    if min_amount and max_amount and max_amount!=min_amount
      desc += " Subject to a minimum of  Rs. #{min_amount}" if min_amount
      desc += ", maximum of Rs. #{max_amount}" if max_amount
    end
    desc
  end

  def Fee.fees_for_insurance_products(fees)
    fees.select {|fee| fee.payable_on == :policy_issue_date}
  end

  def self.payable_dates
    PAYABLE
  end

  def fees_for(loan)
    return amount if amount
    return [[min_amount || 0 , (percentage ? percentage * loan.amount : 0)].max, max_amount || (1.0/0)].min
  end
  
  def self.applicable(loan_ids, hash = {})
    date = hash[:date] || Date.today

    if loan_ids == :all
      query    = " AND l.disbursal_date is not NULL"
      query   += " AND l.disbursal_date<='#{date.strftime('%Y-%m-%d')}'"
    else
      loan_ids = loan_ids.length>0 ? loan_ids.join(",") : "NULL"
      query    = "AND l.id IN (#{loan_ids})"
    end   

    payables = Fee.properties[:payable_on].type.flag_map
    applicables = repository.adapter.query(%Q{
                                SELECT l.id loan_id, l.client_id client_id, 
                                       SUM(if(f.amount>0, convert(f.amount, decimal), l.amount*f.percentage)) fees_applicable, 
                                       f.payable_on payable_on                                       
                                FROM loan_products lp, fee_loan_products flp, fees f, loans l 
                                WHERE flp.fee_id=f.id AND flp.loan_product_id=lp.id AND lp.id=l.loan_product_id #{query}
                                      AND l.deleted_at is NULL AND l.rejected_on is NULL
                                GROUP BY l.id;})
    fees = []

    applicables.each{|fee|
      if payables[fee.payable_on]==:loan_installment_dates
        installments = loans.find{|x| x.id==fee.loan_id}.installment_dates.reject{|x| x > date}.length
        fees.push(FeeApplicable.new(fee.loan_id, fee.client_id, fee.fees_applicable.to_f * installments))
      else
        fees.push(FeeApplicable.new(fee.loan_id, fee.client_id, fee.fees_applicable.to_f))
      end
    }
    fees
  end

  def self.paid(loan_ids, date=Date.today)    
    Payment.all(:type => :fees, :loan_id => loan_ids, :received_on.lte => date).aggregate(:loan_id, :amount.sum).to_hash
  end

  def self.due(loan_ids, date=Date.today)
    fees_applicable = self.applicable(loan_ids, {:date => date}).group_by{|x| x.loan_id}
    fees_paid       = self.paid(loan_ids, {:date => date})
    fees = {}
    loan_ids.each{|lid|
      applicable = fees_applicable[lid].first if fees_applicable.key?(lid) and fees_applicable[lid].length>0
      next if not applicable
      paid      = fees_paid.key?(lid) ? fees_paid[lid] : 0
      fees[lid]  = FeeDue.new((applicable ? applicable.fees_applicable.to_f : 0), paid, ((applicable ? applicable.fees_applicable : 0) - paid).to_i)
    }
    fees
  end

  def self.overdue(date=Date.today)
    fees = self.applicable(:all, :date => date).map{|app| [app.loan_id, app.fees_applicable.to_i]}.to_hash
    paid = Payment.all(:type => :fees, :loan_id.not => nil, :received_on.lte => date).aggregate(:loan_id, :amount.sum).to_hash
    (fees - paid).reject{|lid, a| a<=0}
  end

  # faster compilation of fee collected for/by a given obj. This obj can be a branch, center, area, region or staff member
  # fee_collected_type here is relevant only for the case of staff member. This comes into play when we need all the fee collected under centers
  # managed by the staff member.
  # TODO:  rewrite it using Datamapper
  def self.collected_for(obj, from_date=Date.min_date, to_date=Date.max_date, fee_collected_type = :created)
    if obj.class==Branch
      from  = "branches b, centers c, clients cl, payments p, fees f"
      where = %Q{
                  b.id=#{obj.id} and c.branch_id=b.id and cl.center_id=c.id and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    elsif obj.class==Center
      from  = "centers c, clients cl, payments p, fees f"
      where = %Q{
                  c.id=#{obj.id} and cl.center_id=c.id and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    elsif obj.class==ClientGroup
      from  = "client_groups cg, clients cl, payments p, fees f"
      where = %Q{
                 cg.id=#{obj.id} and cg.id=c.client_group_id and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                 and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
              };
    elsif obj.class==Client
      from  = "clients cl, payments p, fees f"
      where = %Q{
                 p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                 and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
              };
    elsif obj.class==Area
      from  = "areas a, branches b, centers c, clients cl, payments p, fees f"
      where = %Q{
                  a.id=#{obj.id} and a.id=b.area_id and c.branch_id=b.id and cl.center_id=c.id 
                  and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    elsif obj.class==Region
      from  = "regions r, areas a, branches b, centers c, clients cl, payments p, fees f"
      where = %Q{
                  r.id=#{obj.id} and r.id=a.region_id and a.id=b.area_id and c.branch_id=b.id and cl.center_id=c.id 
                  and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    elsif obj.class==StaffMember
      if fee_collected_type == :created
        from  = "payments p, fees f"
        where = %Q{
                  p.received_by_staff_id=#{obj.id} and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
      elsif fee_collected_type == :managed
        from  = "centers c, clients cl, payments p, fees f"
        where = %Q{
                  c.manager_staff_id=#{obj.id} and cl.center_id=c.id and p.client_id=cl.id and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
      end
    elsif obj.class==LoanProduct
      from  = "loans l, payments p, fees f"
      where = %Q{
                  l.id = p.loan_id and l.loan_product_id = #{obj.id} and l.deleted_at is NULL and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    elsif obj.class==FundingLine
      from  = "loans l, payments p, fees f"
      where = %Q{
                  l.id = p.loan_id and l.funding_line_id = #{obj.id} and l.deleted_at is NULL and p.type=3 and p.fee_id=f.id
                  and p.deleted_at is NULL and p.received_on>='#{from_date.strftime('%Y-%m-%d')}' and p.received_on<='#{to_date.strftime('%Y-%m-%d')}'
               };
    end
    repository.adapter.query(%Q{
                             SELECT SUM(p.amount) amount, f.name name
                             FROM #{from}
                             WHERE #{where}
                             GROUP BY p.fee_id
                           }).map{|x| [x.name, x.amount.to_i]}.to_hash
  end


end
