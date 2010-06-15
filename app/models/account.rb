class Account
  include DataMapper::Resource

  property :id,                Serial  
  property :name,              String
  property :gl_code,           String
  property :parent_account_id,      String
  belongs_to :account, :model => 'Account', :child_key => [:parent_account_id]
  belongs_to :account_type


  validates_present :name 
  validates_present :gl_code
  validates_length  :name,     :minimum => 3
  validates_length  :gl_code,  :minimum => 3  
end



