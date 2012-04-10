require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
  
describe "Account Model" do        
  setup do  
    @account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, :name => Faker::Name.name, :password => 'samy', 
      :password_confirmation => 'samy')     
    @account.save
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
  
  should "destroy an account" do
    account = Account.first
    assert account.destroy 
  end
end   
