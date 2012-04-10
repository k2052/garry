class CartItem      
  include ::MongoMapper::EmbeddedDocument  

  key :type,       String  
  key :price,      Integer
  key :product_id, ObjectId   

  has_many :adjustments  

  def add_adjustment(adjustment)    
    self.adjustments << adjustment if adjustment.is_a?(Adjustment)
  end 

  def add_adjustments(ads)   
    ads.each do |adjustment|    
      self.adjustments << adjustment if adjustment.is_a?(Adjustment)
    end
  end

  def purchase(account)    
    p = self.product()
    if p.purchase(account)     
      p.after_purchase(account)
    else
      errors.add :product, p.errors.full_messages       
    end
  end  

  def after_purchase(account)  
    p = self.product
    p.after_purchase(account) 
  end

  def total()
    return @total if @total     

    price = self.price
    price = self.product.total unless price

    adjustments.each do |a|  
      price += a.amount
    end   

    self.price = price
    @total = self.price

    return @total
  end

  def product()  
    product_type = Kernel.const_get(self.type)
    product_type.find_by_id(self.product_id)
  end
end