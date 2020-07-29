module SemiStatic
  class Squeeze < ApplicationRecord

    # For reference
    #
    # attr_accessible :name, :teaser, :title, :agreement, :form_instructions, :instructions
    # attr_accessible :doc, :company_field, :position_field, :email_footer, :email_subject

    has_attached_file :doc, :path => ":rails_root/private/squeezes/:id/:filename", :url => ":rails_root/private/squeezes/:id/:filename"

    validates_attachment :doc, content_type: { content_type: "application/pdf" }
    validates_attachment_presence :doc

    has_many :entries
    has_many :contacts

    has_many :page_attrs, :as => :page_attrable

    # Like the page attr for Entries and Tags
    def get_attr(k)
      self.page_attrs.find_by_attr_key(k)&.attr_value
    end

    def raw_title
      title
    end

  end
end
