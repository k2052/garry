module Garry
  module Jobs
    class CreateStripe 
      def self.perform(account_id, stripe_token=nil)
        account = ::Account.find_by_id(account_id)  
        begin       
          c_hash = {   
            :description => "Customer #{account.name} for site@demo",
            :email       => account.email
          }   
          
          c_hash[:card] = stripe_token if stripe_token 
          
          customer = ::Stripe::Customer.create(c_hash)   
          
          account.stripe_id     = customer.id       
          account.last_4_digits = customer.active_card.last4 if customer.active_card       
          
          account.save
        rescue ::Stripe::StripeError => e  
          ::Airbrake.notify(
            :error_class   => :create_stripe,
            :error_message => "Failed to create stripe for #{account.name}: #{e.message}",
            :parameters    => {:account => account.name, :account_id => account_id}
          )
        end
      end
    end    
  end  
end