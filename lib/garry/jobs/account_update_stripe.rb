module Garry 
  module Jobs
    class UpdateStripe 
  
      def self.perform(account_id, updates={})
        account = ::Account.find_by_id(account_id)  
        begin 
          customer = ::Stripe::Customer.retrieve(account.stripe_id)       
          # Note customer doesn't seem to respond_to? correctly. My guess is method_missing is used.   
          # That means you should definitely not pass in things you don't know will be saved.
          # Know your params
          updates.each do |k, v| 
            customer.send("#{k}=", v)       
          end   
          customer.save      
          
          account.last_4_digits = customer.active_card.last4 if updates.include?(:card) and customer.active_card      
          
          if updates.include?(:plan)  
            plan = Plan.find_by_id(updates[:plan])
            account.plan_id = plan.id
            account.plan_ids << plan.id 
          end   
          
          account.save
        rescue ::Stripe::StripeError => e  
          ::Airbrake.notify(
            :error_class   => :update_stripe,
            :error_message => "Failed update stripe for #{account.name}: #{e.message}",
            :parameters    => {:account => account.name, :account_id => account_id}
          )
        end
      end
    end    
  end 
end  