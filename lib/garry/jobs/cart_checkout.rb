module Garry 
  module Jobs
    class CartCheckout
      def self.perform(cart_id)  
        cart    = ::Cart.find_by_id(cart_id)  
        account = cart.account
        begin 
          charge = ::Stripe::Charge.create(
            :amount      => cart.total,
            :currency    => "usd",      
            :customer    => account.stripe_id,
            :description => "Charge for #{account.email}"
          ) 
          cart.charge_id     = charge.id  
          cart.charge_amount = charge.amount

          cart.items do |item| 
            if item.destroy      
              item.after_purchase(account)
            else                          
              ::Airbrake.notify(
                :error_class   => :checkout,
                :error_message => "Failed to purchase #{item.product.title}: #{item.errors.full_messages}",
                :parameters    => {:account => account.name, :cart_id => cart_id, :item_id => item.id, :product => item.product.title }
              )
            end
          end     
        
          if cart.save  
            # Do Nothing we are good
          else      
            ::Airbrake.notify(
              :error_class   => :cart,
              :error_message => "Failed to save cart for #{account.name}: #{cart.errors.full_messages}",
              :parameters    => {:account => account.name, :cart_id => cart_id}
            )
          end
        rescue ::Stripe::StripeError => e   
          ::Airbrake.notify(
            :error_class   => :stripe,
            :error_message => "Failed to checkout #{account.name}: #{e.message}",
            :parameters    => {:account => account.name, :cart_id => cart_id}
          )
        end
      end
    end
  end  
end