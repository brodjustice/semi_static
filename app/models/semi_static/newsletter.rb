require "haml"

module SemiStatic
  class Newsletter < ActiveRecord::Base
    attr_accessible :name, :state, :locale, :subtitle
    serialize :draft_entry_ids, Array

    has_many :newsletter_deliveries

    validates :name, :presence => true
    validates_uniqueness_of :name
    validates :locale, :presence => true
    validate :duplicate_draft_entry_ids

    before_save :set_defaults

    STATES = {
      :draft => 0x1,
      :draft_sent => 0x2,
      :published => 0x3
    }

    STATE_CODES = STATES.invert

    def duplicate_draft_entry_ids
      unless draft_entry_ids.uniq.length == draft_entry_ids.length
        errors.add(:draft_entry_ids, "Cannot have the same entry more than once")
        false
      else
        true
      end 
    end

    def set_defaults
      self.state ||= STATES[:draft]
    end

    def draft_entry_titles
      titles = []
      self.draft_entry_ids.each{|e_id|
        unless (e = Entry.find_by_id(e_id)).nil?
          titles << e.title
        end
      }
      titles
    end

    def draft_entry_objects
      entries = []
      draft_entry_ids.each{|e|
        entries << SemiStatic::Entry.find(e)
      }
      entries
    end

    def add_entry(position = nil)
      return if position.nil?
      if position[:prepend] && !position[:prepend].blank?
        draft_entry_ids.unshift(position[:prepend].to_i)
      end
      position[:append] && position[:append].each{|k,v|
        next if v.blank?
        draft_entry_ids.insert(draft_entry_ids.index(k.to_i) + 1, v.to_i)
      }
    end

    def draft_sent
      self.state = STATES[:draft_sent]
      self.save
    end

    # TODO: Methods below til EOF are probably no longer required
    # as we simply send copy of email to be checked manually. The
    # edit view is good enough and these extra views just add confusion.
    def email_object_to_file(email)
      html_dir = Rails.root.join("public", "system", 'semi_static', 'newsletters', self.id.to_s)
      FileUtils.mkdir_p(html_dir)
      file_path = File.join(html_dir, self.name.parameterize)
      File.open(file_path, 'wb') {|f| f.write(Marshal.dump(email))}
    end

    def email_to_file(email)
      attachments = []

      html_dir = Rails.root.join("public", "system", 'semi_static', 'newsletters', self.id.to_s)
      FileUtils.mkdir_p(html_dir)

      if email.attachments.any?
        attachments_dir = File.join(html_dir, 'attachments')
        FileUtils.mkdir_p(attachments_dir)

        email.attachments.each do |attachment|
          filename = attachment.filename.gsub(/[^\w.]/, '_')
          path = File.join(attachments_dir, filename)
          unless File.exists?(path) # true if other parts have already been rendered
            File.open(path, 'wb') { |f| f.write(attachment.return_body(email).raw_source) }
          end
          attachments << [attachment.filename, "attachments/#{URI.escape(filename)}"]
        end
      end

      content_type = email.part && email.part.first.content_type || email.content_type
      file_path = File.join(html_dir, "#{content_type =~ /html/ ? 'rich' : 'plain'}.html")

      File.open(file_path, 'w') do |f|
        f.write ERB.new(File.read(template_path)).result(binding)
        # f.write Haml::Engine.new(File.read(template_path)).render(binding)
      end
    end

    def template_path
      Engine.root.join('app', 'views', 'semi_static', 'newsletter_mailer', 'draft.html.erb')
      # Engine.root.join('app', 'views', 'semi_static', 'newsletter_mailer', 'draft.html.haml')
    end

    def return_body(email)
      main_body ||= begin
        email_body = (email.part || mail).decoded
        mail.attachments.each do |attachment|
          email_body.gsub!(attachment.url, "attachments/#{attachment.filename}")
        end
        email_body
      end
    end
  end
end
