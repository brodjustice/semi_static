module SemiStatic
  class User < ActiveRecord::Base

    has_and_belongs_to_many :roles, :join_table => :semi_static_role_users
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable, :rememberable, :registerable
    devise :database_authenticatable, :recoverable, :trackable, :validatable
  
    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
    attr_accessible :name, :surname, :role_ids
  
  
    validates_presence_of :roles
    validates_uniqueness_of :email
    validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :allow_nil => true
  
    def top_role(allow_new_record = false)
      return Role.new(:name => 'visitor') if self.new_record? && !allow_new_record
      # Must be a more efficient way of doing this? Probably
      # with a DB where(:level => ?) query
      Role.find_by_level(self.roles.collect{|r| r.level}.min)
    end
  
    # This does not work on new_records
    def has_role?(role)
      # Code below is much faster, but then you need to check the array which can be slower
      # self.roles.where(:name => role)
      self.roles.exists?(:name => role)
    end
  
    def admin?
      has_role?('admin')
    end
  
    def user?
      has_role?('user')
    end
  
    def fullname
      [self.name, self.surname].join(' ')
    end
  end
end
