module SemiStatic
  class Squeeze < ActiveRecord::Base

    # For reference
    #
    # attr_accessible :name, :teaser, :title, :agreement, :form_instructions, :instructions
    # attr_accessible :doc, :company_field, :position_field, :email_footer, :email_subject

    has_attached_file :doc, :path => ":rails_root/private/squeezes/:id/:filename", :url => ":rails_root/private/squeezes/:id/:filename"

    validates_attachment :doc, content_type: { content_type: "application/pdf" }
    validates_attachment_presence :doc

    has_many :entries
    has_many :contacts
  end
end
