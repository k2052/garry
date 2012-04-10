require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
 
describe "Product Model" do 
  setup do                                        
    @product  = Product.new(:price => 5005, :title => Faker::Name.name)    
    @product2 = Product.new(:price => 5005, :title => Faker::Name.name)  
    @product.save
    @product2.save
    @account  = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, :name => Faker::Name.name, :password => 'samy', 
      :password_confirmation => 'samy') 
    @account.save                             
    @account = Account.first(:id => @account.id)  
    cu = Stripe::Customer.retrieve(@account.stripe_id)   
    card = {
      :number    => 4242424242424242,
      :exp_month => 8,
      :exp_year  => 2013
    } 
    cu.card = card
    cu.save
  end
  
  should "create a new product model instance" do      
    @product.save
    assert @product.errors.size == 0
  end            
  
  should "should purchase a product" do    
    @product.purchase(@account)  
    @product = Product.find_by_id(@product.id)
    wont_be_nil @product.charge_id   
           
    @product.destroy
  end    
  
  should "add adjustments to a product" do       
    shipping = Adjustment.new(:label => :shipping, :amount => 988)
    tax      = Adjustment.new(:label => :text, :amount => 2088)  
    @product2.add_adjustments([shipping, tax])      
    @product2.save
        
    assert @product2.total == 8081  
    @product2.purchase(@account) 
    @product2 = Product.find_by_id(@product2.id)      
    assert @product2.charge_amount == 8081    
    
    @product2.destroy
  end             
end