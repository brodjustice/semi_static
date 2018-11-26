module SemiStatic
  class JobPosting < ApplicationRecord

    has_attached_file :organisation_logo,
       :styles => { :desktop=> "1500x300#", :mobile => "750x300#", :standard => "250x250#" },
       :convert_options => { :desktop => "-strip -gravity Center -quality 80",
                             :mobile => "-strip -gravity Center -quality 80" ,
                             :standard => "-strip -gravity Center -quality 80" }

    validates_attachment_content_type :organisation_logo, :content_type => ['image/jpeg', 'image/png', 'image/gif']

    has_many :entries

  end
end
