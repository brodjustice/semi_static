module SemiStatic
  class Hreflang < ApplicationRecord
    belongs_to :seo, :dependent => :destroy

    validates :locale, uniqueness: { scope: :seo_id, message: "Can not have duplicate hreflangs with same locale for same webpage" }
    validate :load_url

    def load_url
      `curl #{self.href} -o '/dev/null' 2>&1`
      unless $?.success?
        errors.add(:href, "URL cannot be loaded")
      end
    end

    def siblings
      self.seo&.hreflangs.select{|hr| !hr.new_record? }
    end

  end
end
