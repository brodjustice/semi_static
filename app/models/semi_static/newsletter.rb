module SemiStatic
  class Newsletter < ActiveRecord::Base
    attr_accessible :name, :state, :locale
    serialize :draft_entry_ids, Array

    has_many :newsletter_deliveries

    validates :name, :presence => true
    validates :locale, :presence => true

    before_save :set_defaults

    STATES = {
      :draft => 0x1,
      :published => 0x2
    }

    STATE_CODES = STATES.invert

    def set_defaults
      self.state ||= STATES[:draft]
    end

    def draft_entry_titles
      self.draft_entry_ids.collect{|e_id| Entry.find_by_id(e_id).title }
    end

  end
end
