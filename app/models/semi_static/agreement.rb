module SemiStatic
  class Agreement < ApplicationRecord
    
    has_and_belongs_to_many :contacts, :join_table => :semi_static_agreements_contacts

    scope :locale, -> (locale){where("locale = ?", locale.to_s)}
    scope :subscriber, -> {where(:add_to_subscribers => true)}

    before_update :readonly
    before_destroy :readonly

    def readonly
      #
      # Can only change the ticked_by_default or display attributes
      #
      unless self.contacts.empty? ||
        self.changed.size == 0 ||
        (self.changed.size == 1 && self.changed.include?('ticked_by_default')) ||
        (self.changed.size == 1 && self.changed.include?('display')) ||
        (self.changed.size == 2 && self.changed.include?('display') && self.changed.include?('ticked_by_default'))
 
        self.errors.add(:base, 'Cannot delete or edit this agreement in the way you have attempted, you must remove contacts first or unset only the display or ticked attributes')
        false
      end
    end

  end
end
