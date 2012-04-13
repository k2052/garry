PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)      
require File.expand_path('../../config/boot', __FILE__)

require File.expand_path(File.dirname(__FILE__) + '/../lib/garry.rb')  
require File.expand_path(File.dirname(__FILE__) + '/mock_models/Account.rb')   
require File.expand_path(File.dirname(__FILE__) + '/mock_models/Cart.rb')  
require File.expand_path(File.dirname(__FILE__) + '/mock_models/Product.rb')   
      
require 'stripe'
Stripe.api_key = ENV['STRIPE_KEY']        

class MiniTest::Unit::TestCase
  include Rack::Test::Methods
end
