require 'ffaker'   
PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)      
require File.expand_path(File.dirname(__FILE__) + '/../lib/garry.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Account.rb')   
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Cart.rb')  
require File.expand_path(File.dirname(__FILE__) + '/../test/mock_models/Product.rb')   

require 'stripe'
Stripe.api_key = ENV['STRIPE_KEY']

shell.say "Create some accounts. 10 to be exact"

10.times do |i|    
  account = Account.new(:email => Faker::Internet.email, :username => Faker::Internet.user_name, :name => Faker::Name.name, :password => 'testpass', 
    :password_confirmation => 'testpass')    
  account.save 
       
  account = Account.find_by_id(account.id)  
  cu = Stripe::Customer.retrieve(account.stripe_id)   
  card = {
    :number    => 4242424242424242,
    :exp_month => 8,
    :exp_year  => 2013
  } 
  cu.card = card
  cu.save
end