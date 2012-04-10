class Adjustment  
  include ::MongoMapper::EmbeddedDocument
               
  key :label,      String
  key :amount,     Integer
end  
