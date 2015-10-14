module SemiStatic
  class Sidebar < ActiveRecord::Base
    attr_accessible :title, :body, :bg, :color, :bg_color, :style_class

    has_attached_file :bg, :styles => {:bar => "326x>"}, :convert_options => { :bar => "-strip -gravity Center -quality 80"}

    has_many :entries

    validates_attachment_content_type :bg, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  end
end