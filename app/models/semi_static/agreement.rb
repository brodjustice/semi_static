module SemiStatic
  class Agreement < ActiveRecord::Base
    attr_accessible :body, :display, :locale, :ticked_by_default, :add_to_subscribers

    has_and_belongs_to_many :contacts, :join_table => :semi_static_agreements_contacts

    scope :locale, lambda {|locale| where("locale = ?", locale.to_s)}
    scope :subscriber, where(:add_to_subscribers => true)

    before_update :readonly
    before_destroy :readonly

    def readonly
      unless self.contacts.empty?
        self.errors.add(:base, 'Cannot delete or edoit thus agreement, you must remove contacts first or unset the display attribute')
        false
      end
    end

  end
end
