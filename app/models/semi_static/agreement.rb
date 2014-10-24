module SemiStatic
  class Agreement < ActiveRecord::Base
    attr_accessible :body, :display, :locale, :ticked_by_default

    has_and_belongs_to_many :contacts, :join_table => :semi_static_agreements_contacts

    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}

    before_destroy :check_contacts

    def check_contacts
      unless self.contacts.empty?
        self.errors.add(:base, 'Cannot delete, remove contacts first or unset the display attribute')
        false
      end
    end

  end
end
