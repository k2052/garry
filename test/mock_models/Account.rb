require File.expand_path(File.dirname(__FILE__) + '/Cart.rb')
class Account
  include MongoMapper::Document
  include Garry::Account
end