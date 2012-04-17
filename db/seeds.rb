require 'ffaker'   
PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)      
require File.expand_path(File.dirname(__FILE__) + '/../lib/garry.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Account.rb')   
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Cart.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Product.rb')   

require 'stripe'
Stripe.api_key = ENV['STRIPE_KEY']

shell.say "Creating some accounts. 3 to be exact"

3.times do |i|    
  account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, :name => Faker::Name.name, :password => 'testpass', 
    :password_confirmation => 'testpass')    
  account.save 
       
  account = Account.find_by_id(account.id)  
  card = {
    :number    => 4242424242424242,
    :exp_month => 8,
    :exp_year  => 2013
  } 
  account.update_stripe(:card => card)
end  

shell.say "Creating some products. 10 to be exact"
5.times do |i|   
  product = Product.new(:price => 5005, :title => Faker::Name.name) 
  product.save
end 
 
shell.say "Purchasing a few products."
                       
account = Account.no_purchases.first

products = Product.all(:limit => 5)

products.each do |product|  
  account.purchase(product)
end
