require "haml"

module SemiStatic
  class Newsletter < ActiveRecord::Base
    attr_accessible :name, :state, :locale, :subtitle, :salutation, :salutation_type, :salutation_pre_text, :salutation_post_text, :css
    attr_accessible :sender_address, :max_image_attachments, :banner_id, :title, :subject, :website_url

    # This is a serialized hash, for example:
    # {12 => {}, 39 => {:img_url => './system/image-x.jpg'}, 199 => {}}
    # The order has meaning here, so ruby > 1.9 is reqired to preserve the order of the hash
    #
    # Valid keys are:
    #  :img_url - the url to use for the nutshell image in the newsletter
    #  :layout - :double, :single_left, :text_only, etc.
    #
    serialize :draft_entry_ids, Hash

    has_many :newsletter_deliveries
    has_one :tag
    has_many :subscribers, :through => :newsletter_deliveries
    belongs_to :banner

    validates :name, :presence => true
    validates_uniqueness_of :name
    validates :locale, :presence => true

    before_save :set_defaults
    before_create :create_newsletter_tag

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

    # Number also acts as mask: 0xF00 is the number of images in layout, 0x1000 is set if there is text
    ENTRY_LAYOUT_IMAGE_MASK = 0xF00
    ENTRY_LAYOUT_TEXT_MASK = 0x1000
    ENTRY_LAYOUTS = {
      :double => 0x1101, :single_left => 0x1102, :text_only => 0x1003, :double_text => 0x1004, :image_above => 0x1105,
      :float_left_no_link => 0x1106, :image_center_no_link => 0x1107, :float_left => 0x1108, :text_only_no_link => 0x1009,
      :image_only_no_link => 0x010a
    }

    ENTRY_LAYOUT_CODES = ENTRY_LAYOUTS.invert

    def self.layout_has_text?(i=0)
      i.nil? ? false : ((i & ENTRY_LAYOUT_TEXT_MASK) > 0)
    end

    def self.layout_has_image?(i=0)
      i.nil? ? false : ((i & ENTRY_LAYOUT_IMAGE_MASK) > 0)
    end

    def create_newsletter_tag
      if self.tag.nil?
        self.tag = SemiStatic::Tag.create(:locale => self.locale, :name => self.name, :menu => false, :icon_in_menu => false)
      end
    end

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

    def set_layout(e_id, layout)
      self.draft_entry_ids[e_id.to_i][:layout] = layout.to_i
      self.save
    end

    def swap_entry_image(e_id)
      e = Entry.find_by_id(e_id)
      urls = ([ e.newsletter_img.present? ? e.newsletter_img(:crop) : nil, e.newsletter_img.present? ? e.newsletter_img(:original) : nil, e.news_img.present? ? e.news_img.url(:original) : nil, e.img.present? ? e.img.url(:panel) : nil ].concat( e.photos.collect{|p| p.img.url(:boxpanel)}).compact)
      if urls.size < 2
        nil
      else
        i = urls.index(self.draft_entry_ids[e_id][:img_url]) || 0
        self.draft_entry_ids[e_id][:img_url] = urls[i + 1]
        self.save
      end
    end

    def add_entry(entry = nil, at_end = false)
      return if entry.nil?

      # Get new entry to be inserted
      entry.kind_of?(SemiStatic::Entry) ? e = entry : e = Entry.find_by_id(entry[:new_entry_id])

      # Must now completely rebuild the hash in the correct order, also if we change inplace
      # then the serialzed attribute is not saved to the DB, so it's best to dup and rebuild
      # to avoid the problem
      e_ids = self.draft_entry_ids.deep_dup
      self.draft_entry_ids = {}
      if e_ids.empty? || at_end
        self.draft_entry_ids_will_change!
        self.draft_entry_ids = e_ids.merge(e.id => {:img_url => get_best_img(e), :layout => ENTRY_LAYOUTS[:text_only]})
        self.draft_entry_ids_will_change!
        self.save
        # Arrrrgggghhhhhh!!! Is this a Rails bug? No matter what we do here, the new contents of the draft_entry_ids
        # simply refuses to be saved to the DB. It's impossible to update at this point!!!
      else
        e_ids.collect{|k,v|
          if k == entry[:id].to_i
            if entry[:position] == 'After'
              self.draft_entry_ids[k] = v
              self.draft_entry_ids[e.id] = {:img_url => get_best_img(e), :layout => ENTRY_LAYOUTS[:text_only]}
            else
              self.draft_entry_ids[e.id] = {:img_url => get_best_img(e), :layout => ENTRY_LAYOUTS[:text_only]}
              self.draft_entry_ids[k] = v
            end
          else
            self.draft_entry_ids[k] = v
          end
        }
      end
      self.save
    end

    def published
      self.state = STATES[:published]
      self.save
    end

    def remove_pending
      self.newsletter_deliveries.pending.destroy_all
    end

    def draft_sent
      self.state = STATES[:draft_sent]
      self.save
    end

    def remove_entry_id(id)
      self.draft_entry_ids.delete(id.to_i)
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
          if ((nd = self.newsletter_deliveries.find_by_subscriber_id(id)).present? && (nd.state == NewsletterDelivery::STATES[:pending]))
            #
            # We already have a pending delivery for this subscriber
            # so just update it again so the the timestamp is correct
            #
            nd.state = NewsletterDelivery::STATES[:pending]
            nd.save
          else
            nd = NewsletterDelivery.create(:state => NewsletterDelivery::STATES[:pending])
            nd.subscriber = s
            nd.newsletter = self
            nd.save
          end
        end
      }
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
