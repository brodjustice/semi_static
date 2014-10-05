module SemiStatic
  class Banner < ActiveRecord::Base
    attr_accessible :name, :tag_line, :img

    has_many :entries
    has_many :tags

    has_attached_file :img,
       :styles => { :desktop=> "1500x300#",
                    :mobile => "750x300#" },
       :convert_options => { :desktop => "-strip -gravity Center -quality 80",
                             :mobile => "-strip -gravity Center -quality 80" }
  end
end
