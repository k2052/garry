require 'ffaker'

shell.say "Create some accounts. 10 to be exact"

unless defined?(Account)       
  class Account
    include MongoMapper::Document
    include Garry::Account
  end
end

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