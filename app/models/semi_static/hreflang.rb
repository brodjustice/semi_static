module SemiStatic
  class Hreflang < ActiveRecord::Base
    belongs_to :seo, :dependent => :destroy

    validates :locale, uniqueness: { scope: :seo_id, message: "Can not have duplicate hreflangs with same locale for same webpage" }
    validate :load_url

    def load_url
      `curl #{self.href} -o '/dev/null' 2>&1`
      unless $?.success?
        errors.add(:href, "URL cannot be loaded")
      end
    end

  end
end
