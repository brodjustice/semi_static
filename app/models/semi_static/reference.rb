module SemiStatic
  class Reference < ApplicationRecord

    include Pages

    has_one :seo, :as => :seoable
  
    has_attached_file :logo,
       :styles => {
         :micro=> "40x40#",
         :mini=> "96x96",
         :small=> "148x>",
         :thumb=> "180x180#",
         :bar=> "304x>"
       },
       :convert_options => { :micro => "-strip -gravity Center",
                             :mini => "-strip -gravity Center",
                             :small => "-strip",
                             :bar => "-strip",
                             :thumb => "-strip -gravity Center" }
    default_scope {order(:position)}
    scope :side_bar, -> {where('show_in_side_bar = ?', true)}
    scope :locale, -> (locale){where("locale = ?", locale.to_s)}

    def admin_only
      false
    end
  end
end
