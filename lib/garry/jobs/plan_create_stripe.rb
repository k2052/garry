module Garry 
  module Jobs  
    class PlanCreateStripe    
      def self.perform(plan_id)      
        plan = ::Plan.find_by_id(plan_id)
        
        begin  
          p = ::Stripe::Plan.create(
            :amount   => plan.amount,
            :interval => plan.interval,
            :name     => plan.title,
            :currency => plan.currency,
            :id       => plan.name
          )
          plan.stripe_id = p.id
          plan.save 
        rescue ::Stripe::StripeError => e  
          ::Airbrake.notify(
            :error_class   => :create_stripe,
            :error_message => "Failed to create stripe plan for #{plan.name}: #{e.message}",
            :parameters    => {:plan_id => plan_id}
          )
        end
      end
    end
  end
end