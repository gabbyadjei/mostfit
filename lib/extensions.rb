module Misfit
  module Extensions
    module Browse
      def self.included(base)
        Merb.logger.info "Included Misfit::Extensions::Browse by #{base}"
        base.show_action(:centers_paying_today)
        base.show_action(:regions)
      end

      def before
        if session.user.role == :staff_member
          @staff_member = session.user.staff_member
          @branches = Branch.all(:manager => @staff_member)
          @centers = Center.all(:manager => @staff_member)
          @template = 'browse/for_staff_member'
        end
      end

      def centers_paying_today
        @date = params[:date] ? Date.parse(params[:date]) : Date.today
        center_ids = LoanHistory.all(:date => Date.today).map{|x| x.center_id}.uniq.join(',')
        center_ids = "NULL" if center_ids.blank?
        client_ids = repository.adapter.query(%Q{SELECT c.id FROM clients c WHERE c.center_id IN (#{center_ids})})
        @data = repository.adapter.query(%Q{SELECT c.id as id, c.name name, SUM(principal_due) pd, SUM(interest_due) intd, 
                                                   SUM(principal_paid) pp, SUM(`interest_paid`) intp
                                        FROM loan_history, centers c
                                        WHERE center_id IN (#{center_ids}) AND date='#{@date.strftime('%Y-%m-%d')}' AND c.id=loan_history.center_id
                                        GROUP BY center_id ORDER BY c.name})
        @disbursals = Loan.all(:client_id => client_ids, :scheduled_disbursal_date => @date)
        render :template => 'dashboard/today'
      end

      def regions
        redirect "/regions"
      end
    end # Browse

    module User
      CUD_Actions =["create", "new", "edit", "update", "destroy"]
      #add hooks to before and after can_access? and can_manage? methods to override their behaviour
      # here we add hooks to see if the user can manage a particular instance of a model.
      def self.included(base)
        Merb.logger.info "Included Misfit::Extensions::User by #{base}"
        base.class_eval do
          alias :old_can_access? :can_access?
          alias :can_access? :_can_access?

          #congratulations you have over-ridden the base methods
          # you can now pollute away
        end
      end

      def can_approve?(loan)
        if role == :staff_member
          return (loan.client.center.manager == staff_member or loan.client.center.branch.manager == staff_member)
        end
        return false if role == :read_only
        return true
      end

      def additional_checks
        id = @route[:id]
        model = Kernel.const_get(@model.to_s.capitalize)
        if model == Loan
          l = Loan.get(id)
          return ((l.client.center.manager == self.staff_member) or (l.client.center.branch.manager == self.staff_member))
        elsif model == Client
          c = Client.get(id)
          return ((c.center.manager == self.staff_member) or (c.center.branch.manager == self.staff_member))
       elsif model == Center
          center = Center.get(id)
          if @action != "show"
            return center.branch.manager == self.staff_member
          else
            return center.manager == self.staff_member
          end
        elsif model.relationships.include?(:manager)
          o = model.get(id)
          return true if o.manager == self.staff_member
        else
          return false
        end
      end

      def _can_access?(route,params = nil)
        # more garbage
        return true if role == :admin
        return true if route[:controller] == "graph_data"
        @route = route
        @controller = (route[:namespace] ? route[:namespace] + "/" : "" ) + route[:controller]
        @model = route[:controller].singularize.to_sym
        @action = route[:action]
        return true if @action == "redirect_to_show"
        r = (access_rights[@action.to_s.to_sym] or access_rights[:all])
        return false if @action == "approve" and role == :data_entry
        return false if role == :read_only and CUD_Actions.include?(@action)
        return false if r.nil?
        if role == :staff_member
          if @route.has_key?(:id) and @route[:id]
            return additional_checks
          end
          if @controller == "payments"
            c = Center.get(@route[:center_id])
            return ((c.manager == staff_member or c.branch.manager == staff_member) and r.include?(:payments))
          end
          if @controller == "data_entry/payments"
            if route[:action] == "by_center"
              c = Center.get(params[:center_id])
              return c ? (c.manager == staff_member or c.branch.manager == staff_member) : false
            end
            if @route[:action] == "by_staff_member"
              c = Center.get(params[:staff_member_id])
              return c ? (c.manager == staff_member or c.branch.staff_member == staff_member) : false
            end
          end
        end
        r.include?(@controller.to_sym) || r.include?(@controller.split("/")[0].to_sym)
      end
    end #User

    def self.hook
      # includes the modules in their respective classes
      self.constants.each do |mod|
        object = Kernel.const_get(mod.to_s)
        object.class_eval do
          Merb.logger.info("Hooking extensions for #{mod}")
          include module_eval("Misfit::Extensions::#{mod}")
        end
      end
    end
  end
end
