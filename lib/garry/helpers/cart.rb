module Garry
  module CartHelpers 
    def current_cart() 
      if current_account 
        return current_account.cart 
      else       
        cart = Cart.find_by_id(session[:cart_id]) if session[:cart_id]  
        return cart if cart  
        cart = Cart.new()
        cart.save
        session[:cart_id] = cart.id
        return cart
      end
    end   
  end  
end