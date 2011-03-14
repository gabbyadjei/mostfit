class InsurancePolicy
  include DataMapper::Resource

  POLICY_STATUSES = [:active, :expired, :claim_pending, :claim_settled]
  COVER_FOR       = [:self, :spouse, :son, :daughter, :mother, :father]
  property :id, Serial
  property :application_number, String, :nullable => true
  property :policy_no, String, :nullable => false
  property :sum_insured, Integer, :nullable => false
  property :premium, Integer, :nullable => false
  property :date_from, Date, :nullable => false
  property :date_to, Date, :nullable => false
  property :nominee, String, :nullable => true
  property :status, Enum.send("[]", *POLICY_STATUSES), :nullable => true
  property :cover_for, Enum.send("[]", *COVER_FOR), :nullable => true, :default => 'self'

  belongs_to :insurance_product
  belongs_to :client
  belongs_to :loan, :nullable => true

  before :valid?, :set_status

  validates_with_method :end_date_after_start_date

  def self.statuses
    POLICY_STATUSES
  end

  def description
    "#{insurance_product.name}: Rs.#{sum_insured}"
  end

  private
  def set_status
    if self.date_to and self.is_a?(Date)
      self.status = Date.today > self.date_to ? :expired : :active    
    end
  end

  def end_date_after_start_date
    return [false, "End date must be after start date"] if date_to.is_a?(Date) and date_from.is_a?(Date) and date_to < date_from
    true
  end

end
