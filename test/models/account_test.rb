require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
  
describe "Account Model" do        
  setup do  
    @account = Account.first(:last_4_digits.ne => nil)
  end                  
  
  should "save an account model instance" do    
    account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, :name => Faker::Name.name, :password => 'samy', 
      :password_confirmation => 'samy')
    account.save
    assert account.errors.size == 0   
  end    
  
  should "create customer on stripe" do  
    account = Account.find_by_id(@account.id)
    wont_be_nil account.stripe_id
  end   
  
  should "update a customer on stripe" do   
    account = Account.find_by_id(@account.id)  
    card = {
      :number    => 4242424242424242,
      :exp_month => 8,
      :exp_year  => 2013
    } 
    account.update_stripe(:card => card)    
    account = Account.find_by_id(@account.id) 
    assert_equal account.last_4_digits, 4242
  end  
     
  should "destroy an account" do
    account = Account.first
    assert account.destroy 
  end 
  
  should "purchase a product" do  
    account = Account.find_by_id(@account.id)  
    
    product = Product.new(:price => 5005, :title => Faker::Name.name)     
    product.save      
    account.purchase(product)    
    account = Account.find_by_id(@account.id)  
    assert account.purchased?(product)
  end
  
  should "return purchased products" do     
    account = Account.purchased.first      
    assert account.purchases.count > 0
  end
  
  should 'return products that are not purchased' do  
    account  = Account.no_purchases.first         
    products = Product.all(:id.ne => account.purchased_ids)
    assert account.purchased?(products.first) == false
  end
end   
