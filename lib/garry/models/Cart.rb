module Garry 
  module Cart  
    def self.included(klass)
      klass.class_eval do
        key :account_id,    ObjectId
        key :session_id,    String
        key :charge_id,     String   
        key :charge_amount, Float

        belongs_to :account     

        has_many :items, :class => CartItem  
      end
    end            
  
    def add(item)  
      unless item.is_a?(CartItem)
        item = CartItem.new(:type => item.class, :price => item.price, :product_id => item.id)   
      end
    
      self.items << item
    end  
  
    def remove(item) 
      self.items.delete_if {|i| i.id == item.id}         
    end

    def checkout()    
      return true if self.charge_id
      return Jobs::CartCheckout::perform(self.id) if Padrino.env == :development or Padrino.env == :test   
      Resque.enqueue(Jobs::CartCheckout, self.id)
    end  
  
    def in_cart?(object)    
      self.items.each do |item|      
        return true if item.product_id == object.id 
      end
    
      return false
    end
  
    def total()    
      return @total if @total 
    
      totals = self.items.map { |item| item.total } 
      @total = totals.inject(:+)  
      return @total
    end
    
    # Its probably best to overide this so you get correct objects. Instead of GProduct's
    def items_full(query={})    
      product_ids = self.items.map { |i| i.product_id }   
      GProduct.all({:id => product_ids}.merge!(query))
    end
  end 
end