require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
 
describe "Cart Model" do       
  context "cart" do  
    setup do      
      @account_c = Account.first(:last_4_digits.ne => nil, :cart_id => nil)         
      cart = Cart.new(:account_id => @account_c.id)  
      cart.save
      assert cart.errors.size == 0  
      
      @account_c.cart = cart
      @account_c.save   
      assert @account_c.cart.is_a?(Cart)
    end               

    should "add item to cart and checkout then reset cart" do    
      p = Product.new(:price => 5005, :title => 'Test Product')  
      assert p.save, p.errors.full_messages

      cart = @account_c.cart     
      cart.add(p)       
      cart.save  
      assert cart.items.count > 0  
      assert cart.items_full.count > 0        
      assert GProduct.find_by_id(p.id).id == p.id
            
      cart.checkout       
      cart = Cart.find_by_id(cart.id)
      wont_be_nil cart.charge_id     
      
      cart.items = []    
      cart.save
      assert cart.items.count == 0
    end       

    should "create cart items with adjustments for shipping and tax and then checkout" do  
      @product = Product.first(:price => 5005)     
    
      @item    = CartItem.new(:type => @product.class, :product_id => @product.id)
      shipping = Adjustment.new(:label => :shipping, :amount => 988)
      tax      = Adjustment.new(:label => :text, :amount => 2088)  
      @item.add_adjustments([shipping, tax])
       
      cart = @account_c.cart
      cart.add(@item)    
      cart.charge_id = nil
      cart.save               
    
      assert cart.total == 8081   
      
      cart.checkout        
      cart = Cart.find_by_id(cart.id)
      wont_be_nil cart.charge_id
      assert cart.charge_amount == 8081
    end 
    
    should "destroy an account and a cart" do   
      account = Account.first
      
      cart = Cart.new(:account_id => @account_c.id)  
      cart.save           
      account.cart = cart     
      account.save   
      account.destroy
      cart = Cart.find_by_id(cart.id)    
      assert cart.nil?
    end
  end
end   