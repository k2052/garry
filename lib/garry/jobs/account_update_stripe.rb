module Garry 
  module Jobs
    class UpdateStripe 
  
      def self.perform(account_id, updates={})
        account = ::Account.find_by_id(account_id)  
        begin 
          customer = ::Stripe::Customer.retrieve(account.stripe_id)        
          updates.each do |k, v|   
            customer.send(k, v)
          end   
          account.last_4_digits = customer.active_card.last4 if updates.include?(:card) and customer.active_card 
          customer.save
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