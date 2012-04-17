require 'ffaker'   
PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)      
require File.expand_path(File.dirname(__FILE__) + '/../lib/garry.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Account.rb')   
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Cart.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Product.rb')   

require 'stripe'
Stripe.api_key = ENV['STRIPE_KEY']

shell.say "Create some accounts. 3 to be exact"

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

shell.say "Create some products. 10 to be exact"
10.times do |i|   
  product = Product.new(:price => 5005, :title => Faker::Name.name) 
  product.save
end