class Product < GProduct   
  include MongoMapper::Document 
  include Garry::Purchasable
end