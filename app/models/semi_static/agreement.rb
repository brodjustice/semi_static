module SemiStatic
  class Agreement < ActiveRecord::Base
    attr_accessible :body, :display, :locale, :ticked_by_default
    attr_accessor :agreed

    has_and_belongs_to_many :contacts, :join_table => :semi_static_agreements_contacts

    def agreed
      debugger
      x = 1
    end

    def agreed=(val)
      debugger
      if val == false
        self.contact.delete
      end
    end
  end
end
