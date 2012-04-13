class GarryProduct      
  include MongoMapper::Document 
  include MongoMapperExt::Slugizer     

  key :price,         Integer
  key :title,         String
  key :charge_id,     String   
  key :charge_amount, Integer

  validates_presence_of :title  

  slug_key :title, :unique => true  
  has_many :adjustments  

  def price_dollars() 
    self.price / 100
  end

  def add_adjustment(adjustment)    
    self.adjustments << adjustment if adjustment.is_a?(Adjustment)
  end 

  def add_adjustments(ads)   
    ads.each do |adjustment|  
      self.adjustments << adjustment
    end
  end  

  def total() 
    return @total if @total 
    price = self.price  
    self.adjustments.each do |a|  
      price += a.amount
    end       

    self.price = price
    @total = self.price

    return @total
  end

  def purchase(account) 
    return true if self.charge_id

    return ::Garry::Jobs::ProductPurchase::perform(self.id, account.id) if Padrino.env == :development or Padrino.env == :test   
    Resque.enqueue(::Garry::Jobs::ProductPurchase, self.id, account.id)
  end  

  # This is for users of Garry to implement themselves
  def after_purchase(account)  
    return true
  end         
end 
