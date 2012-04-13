require File.expand_path(File.dirname(__FILE__) + '/Purchasable.rb')
class GProduct     
  include MongoMapper::Document 
  include Garry::Purchasable 
end