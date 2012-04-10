module Garry
  module Jobs
    class CreateStripe 
      def self.perform(account_id)
        account = ::Account.find_by_id(account_id)  
        begin 
          customer = ::Stripe::Customer.create(
            :description => "Customer #{account.name} for site@demo",
            :email       => account.email
          )   
          account.stripe_id = customer.id    
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