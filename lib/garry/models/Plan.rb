module Garry     
  module Plan 
    def self.included(klass)
      klass.class_eval do 
        key :amount,       Integer
        key :interval,     String
        key :title,        String
        key :currency,     String, :default => :usd     
        key :name,         String
        key :stripe_id,    String

        after_save :create_stripe
      end  
    end                     
        
    def create_stripe() 
      unless self.stripe_id 
        return Jobs::PlanCreateStripe::perform(self.id) if Padrino.env == :development or Padrino.env == :test   
        Resque.enqueue(Jobs::PlanCreateStripe, self.id)      
      end  
    end
  end
end