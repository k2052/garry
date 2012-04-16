module Garry 
  module Jobs
    class ProductPurchase   
      def self.perform(product_id, account_id)     
        product = ::GProduct.find_by_id(product_id)
        account = ::Account.find_by_id(account_id)      
              
        begin                     
          charge = ::Stripe::Charge.create(
            :amount      => product.total,
            :currency    => "usd",      
            :customer    => account.stripe_id,
            :description => "Charge for #{account.email}"
          )  

          product.charge_id     = charge.id  
          product.charge_amount = charge.amount     
          
          failure = {
            :error_class   => :purchase,
            :error_message => "Failed to purchase #{product.title} for #{account.name}: #{product.errors.full_messages}",
            :parameters    => {:account => account.name, :product_id => product.id}
          }
        
          if product.save
            account.purchased_ids << object.id       
            account.purchased_type = object.class
            if account.save      
              return product.after_purchase(account)             
            else
              ::Airbrake.notify(failure)
            end
          else    
            ::Airbrake.notify(failure)
          end
        rescue ::Stripe::StripeError => e       
          ::Airbrake.notify(
            :error_class   => :stripe,
            :error_message => "Failed to purchase #{product.title} for #{account.name}: #{e.message}",
            :parameters    => {:account => account.name, :product_id => product.id} 
          )
        end 
      end
    end
  end   
end