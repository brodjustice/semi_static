require "haml"

module SemiStatic
  class Newsletter < ActiveRecord::Base
    attr_accessible :name, :state, :locale, :subtitle, :salutation, :salutation_type, :salutation_pre_text, :salutation_post_text, :css
    attr_accessible :sender_address, :max_image_attachments

    # This is a serialized hash, for example:
    # {12 => {}, 39 => {:img_url => './system/image-x.jpg'}, 199 => {}}
    # The order has meaning here, so ruby > 1.9 is reqired to preserve the order of the hash
    #
    # Valid keys are:
    #  :img_url - the url to use for the nutshell image in the newsletter
    #
    serialize :draft_entry_ids, Hash

    has_many :newsletter_deliveries
    has_one :tag, :dependent => :destroy
    has_many :subscribers, :through => :newsletter_deliveries

    validates :name, :presence => true
    validates_uniqueness_of :name
    validates :locale, :presence => true

    before_save :set_defaults
    # after_create :create_newsletter_tag

    STATES = {
      :draft => 0x1,
      :draft_sent => 0x2,
      :published => 0x3
    }

    STATE_CODES = STATES.invert

    SALUTATION_TYPES = {
      :first_name => 0x1,
      :full_name => 0x2
    }

    SALUTATION_CODES = SALUTATION_TYPES.invert

    # def create_newsletter_tag
    #   self.tag = SemiStatic::Tag.create(:name => self.name, :menu => false, :icon_in_menu => false)
    # end

    def set_defaults
      self.state ||= STATES[:draft]
      # Make sure that there is an image url for each entry
      self.draft_entry_objects.each{|e|
        self.draft_entry_ids[e.id][:img_url] ||= get_best_img(e)
      }
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

    def use_newsletter_img(e_id)
      e = Entry.find_by_id(e_id)
      draft_entry_ids[e_id.to_i][:img_url] = e.newsletter_img(:crop)
      self.save
    end

    def draft_entry_objects
      entries = []
      draft_entry_ids.each{|e, v|
        if (e_obj = SemiStatic::Entry.find_by_id(e))
          entries << e_obj
        else
          # This is a bit messy, should probably be
          # validated elsewhere to make sure that
          # all ids in array are valid
          draft_entry_ids.delete(e)
          self.save
        end
      }
      entries
    end

    def swap_entry_image(e_id)
      e = Entry.find_by_id(e_id)
      urls = ([ e.newsletter_img.present? ? e.newsletter_img(:crop) : nil, e.news_img.present? ? e.news_img.url(:original) : nil, e.img.present? ? e.img.url(:panel) : nil ].concat( e.photos.collect{|p| p.img.url(:boxpanel)}).compact)
      if urls.size < 2
        nil
      else
        i = urls.index(self.draft_entry_ids[e_id][:img_url]) || 0
        self.draft_entry_ids[e_id][:img_url] = urls[i + 1]
        self.save
      end
    end

    def add_entry(entry = nil)
      return if entry.nil?

      # Get new entry to be inserted
      e = Entry.find_by_id(entry[:new_entry_id])

      # Must now completely rebuild the hash in the correct order
      e_ids = self.draft_entry_ids.deep_dup
      self.draft_entry_ids = {}
      e_ids.collect{|k,v|
        if k == entry[:id].to_i
          if entry[:position] == 'After'
            draft_entry_ids[k] = v
            draft_entry_ids[e.id] = {:img_url => get_best_img(e)}
          else
            draft_entry_ids[e.id] = {:img_url => get_best_img(e)}
            draft_entry_ids[k] = v
          end
        else
          draft_entry_ids[k] = v
        end
      }
      self.save
    end

    def published
      self.state = STATES[:published]
      self.save
    end

    def draft_sent
      self.state = STATES[:draft_sent]
      self.save
    end
 
    def order_entries_to_position
      # Must now completely rebuild the hash in the correct order
      e_ids = self.draft_entry_ids.deep_dup
      self.draft_entry_ids = {}
      a = []
      e_ids.each{|e,v|
        a << [Entry.find_by_id(e).position, e] 
      }
      a.sort!
      a.collect{|e| e.last}.each{|e_id|
        draft_entry_ids[e_id] = e_ids[e_id]
      }
      self.save
    end

    def publish(s_ids)
      s_ids.each{|id|
        # Find the subscriber from the id
        unless (s = Subscriber.find_by_id(id)).blank?
          # Is the already a delievery that us marked as pending?
          unless (nd = self.newsletter_deliveries.find_by_subscriber_id(id)) && (nd.state == NewsletterDelivery::STATES[:pending])
            # Create a delivery and mark it as pending
            self.newsletter_deliveries  << s.newsletter_deliveries.create(:state => NewsletterDelivery::STATES[:pending])
          end
        end
      }
    end

    def email_object_to_file(email)
      html_dir = Rails.root.join("public", "system", 'semi_static', 'newsletters', self.id.to_s)
      FileUtils.mkdir_p(html_dir)
      file_path = File.join(html_dir, self.name.parameterize)
      File.open(file_path, 'wb') {|f| f.write(Marshal.dump(email))}
    end

    # TODO: Methods below til EOF are probably no longer required
    # as we simply send copy of email to be checked manually. The
    # edit view is good enough and these extra views just add confusion.
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

    private

    def get_best_img(e)
      if e.newsletter_img.present?
        e.newsletter_img.url(:crop)
      elsif e.news_img.present?
        e.news_img.url(:original)
      elsif e.img.present?
        e.img.url(:panel)
      else
        '/assets/missing.jpg'
      end
    end
  end
end
