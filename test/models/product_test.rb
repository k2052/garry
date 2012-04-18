require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
 
describe "Product Model" do 
  setup do                                        
    @product  = Product.new(:price => 5005, :title => Faker::Name.name)    
    @product2 = Product.new(:price => 5005, :title => Faker::Name.name)  
    @product.save
    @product2.save
    @account_p = Account.no_purchases.first(:last_4_digits.ne => nil)
  end
  
  should "create a new product model instance" do      
    @product.save
    assert @product.errors.size == 0
  end            
  
  should "should purchase a product" do    
    @account_p.purchase(@product)  
    @account_p = Account.find_by_id(@account_p.id)
    assert @account_p.purchased?(@product) == true
  end    
         
  # TODO Verify charge amount
  should "add adjustments to a product" do       
    shipping = Adjustment.new(:label => :shipping, :amount => 988)
    tax      = Adjustment.new(:label => :text, :amount => 2088)  
    @product2.add_adjustments([shipping, tax])      
    @product2.save
        
    assert @product2.total == 8081  
    @account_p.purchase(@product2)
    @account_p = Account.find_by_id(@account_p.id)
    assert @account_p.purchased?(@product2) == true
  end  
end