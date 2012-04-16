require 'digest/sha1'     
require 'bcrypt'  
module Garry   
  module Account   
    def self.included(klass)
      klass.class_eval do    
        extend ClassMethods
        
        attr_accessor :password, :password_confirmation, :generate_password_later, :stripe_token, :force_create_stripe
          :stripe_updates

        key :first_name,       String  
        key :last_name,        String
        key :username,         String     
        key :email,            String
        key :crypted_password, String
        key :salt,             String
        key :stripe_id,        String     
        key :role,             String, :default => :registered   
        key :roles,            Array,  :default => ['registered']     
        key :last_4_digits,    Integer   
        key :purchased_type,   String
        key :purchased_ids,    Array

        # Validations
        validates_presence_of     :email 
        validates_presence_of     :password,                   :if => :password_required
        validates_presence_of     :password_confirmation,      :if => :password_required
        validates_length_of       :password, :within => 4..40, :if => :password_required
        validates_confirmation_of :password,                   :if => :password_required
        validates_length_of       :email,    :within => 3..100
        validates_uniqueness_of   :email,    :case_sensitive => false
        validates_format_of       :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i      
        validates_uniqueness_of   :username     
        validates_format_of       :role,  :with => /[A-Za-z]/
        
        # Callbacks
        before_save :encrypt_password, :if => :password_required  
        after_save :create_stripe, :if => :create_stripe_required  
        after_save :update_stripe, :if => :update_stripe_required  

        # Associations
        has_one :cart, :dependent => :destroy if defined?(::Cart)       
      end
    end 
    
    module ClassMethods   
      def authenticate(email, password)
        account = first(:email => email) if email.present?
        account && account.has_password?(password) ? account : nil
      end
    end 
    
    def name()  
      return "#{self.first_name}, #{self.last_name}" unless self.first_name.nil? 
      return ""
    end

    def name=(n) 
      n = n.split(",").join(" ").split(" ").uniq      
      self.first_name = n[0] if n.length > 0
      self.last_name  = n[1] if n.length >= 1
    end
        
    def role=(role) 
      self[:role] = role     
      self[:roles] << role
    end  
    
    def create_stripe()    
      return Jobs::CreateStripe::perform(self.id, self.stripe_token) if Padrino.env == :development or Padrino.env == :test   
      Resque.enqueue(Jobs::CreateStripe, self.id, self.stripe_token)      
    end   

    def update_stripe(updates={})        
      updates = @stripe_updates if updates.empty? and @stripe_updates
      updates[:card] = @stripe_token if @stripe_token    
          
      return Jobs::UpdateStripe::perform(self.id, updates) if Padrino.env == :development or Padrino.env == :test   
      Resque.enqueue(Jobs::UpdateStripe, self.id, updates)
    end  

    def encrypt_password
      self.crypted_password = ::BCrypt::Password.create(self.password)
    end 

    def password_required       
      return false if generate_password_later
      return crypted_password.blank? || password.present? 
    end

    def has_password?(password)
      ::BCrypt::Password.new(crypted_password) == password
    end   

    def newpass(len=9)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      self.password = newpass  
      self.password_confirmation = newpass
      self.encrypt_password     
      return newpass
    end  
    
    def subscribe(plan)     
      self.update_stripe({:plan => plan.name})
    end  
    
    def purchase(object)      
      object.purchase(self)        
    end    
    
    def purchased(query={})  
      purchased_type = Kernel.const_get(self.purchased_type)
      purchased_type.all({:id => self.purchased_ids}.merge!(query))       
    end
    
    def create_stripe_required()
      return true if @force_create_stripe or self.stripe_id.nil? 
    end    
    
    def update_stripe_required()    
      return false unless self.stripe_id
      return true if @stripe_token or @stripe_updates
    end
  end  
end