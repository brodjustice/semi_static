class InitSemiStaticSchema < ActiveRecord::Migration[5.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"

    create_table "semi_static_agreements", force: :cascade do |t|
      t.text     "body"
      t.boolean  "display",            default: true
      t.boolean  "ticked_by_default",  default: false
      t.string   "locale"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "add_to_subscribers", default: false
    end
    create_table "semi_static_agreements_contacts", id: false, force: :cascade do |t|
      t.integer "agreement_id"
      t.integer "contact_id"
    end
    create_table "semi_static_banners", force: :cascade do |t|
      t.string   "name"
      t.string   "tag_line"
      t.string   "img_file_name"
      t.string   "img_content_type"
      t.integer  "img_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_click_ads", force: :cascade do |t|
      t.integer  "entry_id"
      t.string   "url"
      t.string   "client"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_comments", force: :cascade do |t|
      t.text     "body"
      t.string   "name"
      t.string   "email"
      t.string   "company"
      t.boolean  "agreed",     default: false
      t.integer  "entry_id"
      t.integer  "status"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_contacts", force: :cascade do |t|
      t.string   "name"
      t.string   "surname"
      t.string   "email"
      t.string   "telephone"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "locale",         default: "en"
      t.string   "reason"
      t.string   "title"
      t.string   "company"
      t.string   "address"
      t.string   "position"
      t.string   "country"
      t.string   "employee_count"
      t.string   "branch"
      t.string   "token"
      t.integer  "squeeze_id"
      t.integer  "strategy",       default: 0
    end
    create_table "semi_static_entries", force: :cascade do |t|
      t.string   "title"
      t.text     "body"
      t.text     "summary"
      t.boolean  "home_page"
      t.boolean  "news_item"
      t.integer  "tag_id"
      t.integer  "position",                              default: 0
      t.integer  "summary_length",                        default: 150
      t.boolean  "image_in_news"
      t.boolean  "boolean"
      t.string   "locale",                                default: "en"
      t.string   "style_class",                           default: "normal"
      t.string   "background_colour",                     default: "white"
      t.string   "colour",                                default: "#181828"
      t.string   "header_colour",                         default: "inherit"
      t.string   "img_file_name"
      t.string   "img_content_type"
      t.integer  "img_file_size"
      t.text     "entries"
      t.string   "doc_file_name"
      t.string   "doc_content_type"
      t.integer  "doc_file_size"
      t.text     "doc_description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "banner_id"
      t.boolean  "side_bar",                              default: true
      t.boolean  "side_bar_news",                         default: true
      t.boolean  "side_bar_social",                       default: false
      t.boolean  "side_bar_search",                       default: false
      t.string   "partial",                               default: ""
      t.integer  "entry_position",                        default: 2
      t.integer  "master_entry_id"
      t.boolean  "unrestricted_html",                     default: false
      t.string   "youtube_id_str"
      t.integer  "side_bar_gallery",                      default: 0
      t.boolean  "merge_with_previous",                   default: false
      t.boolean  "facebook_share",                        default: false
      t.boolean  "show_in_documents_tag",                 default: false
      t.text     "image_caption"
      t.string   "tag_line"
      t.boolean  "image_disable",                         default: false
      t.boolean  "raw_html",                              default: false
      t.boolean  "show_image_titles",                     default: false
      t.boolean  "use_as_news_summary",                   default: false
      t.boolean  "link_to_tag",                           default: false
      t.string   "news_img_file_name"
      t.string   "news_img_content_type"
      t.integer  "news_img_file_size",          limit: 8
      t.datetime "news_img_updated_at"
      t.string   "img_dimensions"
      t.integer  "side_bar_tag_id"
      t.integer  "layout_select"
      t.string   "sub_title",                             default: ""
      t.boolean  "simple_text",                           default: false
      t.integer  "sidebar_id"
      t.string   "newsletter_img_file_name"
      t.string   "newsletter_img_content_type"
      t.integer  "newsletter_img_file_size",    limit: 8
      t.datetime "newsletter_img_updated_at"
      t.boolean  "image_popup",                           default: false
      t.boolean  "enable_comments",                       default: false
      t.integer  "comment_strategy"
      t.string   "alt_title",                             default: ""
      t.integer  "acts_as_tag_id"
      t.boolean  "linkedin_share",                        default: false
      t.boolean  "xing_share",                            default: false
      t.boolean  "twitter_share",                         default: false
      t.text     "style"
      t.integer  "event_id"
      t.integer  "squeeze_id"
      t.integer  "gallery_id"
      t.boolean  "email_share",                           default: false
    end
    create_table "semi_static_events", force: :cascade do |t|
      t.string   "name"
      t.text     "description"
      t.string   "time_zone"
      t.datetime "door_time"
      t.datetime "start_date"
      t.datetime "end_date"
      t.integer  "duration"
      t.string   "in_language"
      t.string   "typical_age_range"
      t.string   "location"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "location_address"
      t.string   "offer_price_currency"
      t.float    "offer_price"
      t.boolean  "registration",         default: false
      t.string   "registration_text"
      t.string   "registration_url"
      t.float    "offer_min_price"
      t.float    "offer_max_price"
    end
    create_table "semi_static_fcols", force: :cascade do |t|
      t.string   "name"
      t.integer  "position",   default: 0
      t.text     "content"
      t.string   "locale",     default: "en"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_galleries", force: :cascade do |t|
      t.string   "title"
      t.string   "sub_title"
      t.text     "description"
      t.boolean  "public"
      t.string   "locale"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_hreflangs", force: :cascade do |t|
      t.string   "locale"
      t.string   "href"
      t.integer  "seo_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_links", force: :cascade do |t|
      t.string   "name"
      t.string   "url"
      t.integer  "position",   default: 0
      t.integer  "fcol_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "new_window", default: false
    end
    create_table "semi_static_newsletter_deliveries", force: :cascade do |t|
      t.integer  "state"
      t.integer  "newsletter_id"
      t.integer  "subscriber_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_newsletters", force: :cascade do |t|
      t.string   "name"
      t.integer  "state"
      t.string   "locale",                default: "en"
      t.text     "draft_entry_ids"
      t.text     "html"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "subtitle"
      t.boolean  "salutation",            default: false
      t.integer  "salutation_type"
      t.string   "salutation_pre_text",   default: ""
      t.text     "salutation_post_text",  default: ""
      t.text     "css"
      t.string   "sender_address"
      t.integer  "max_image_attachments", default: 0
      t.integer  "banner_id"
      t.string   "title"
      t.string   "subject"
      t.string   "website_url"
    end
    create_table "semi_static_page_attrs", force: :cascade do |t|
      t.string  "attr_key"
      t.string  "attr_value"
      t.string  "page_attrable_type"
      t.integer "page_attrable_id"
    end
    create_table "semi_static_photos", force: :cascade do |t|
      t.string   "title"
      t.text     "description"
      t.boolean  "home_page",        default: false
      t.string   "img_file_name"
      t.string   "img_content_type"
      t.integer  "img_file_size"
      t.integer  "position",         default: 0
      t.integer  "entry_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "gallery_control",  default: 1
      t.string   "locale"
      t.string   "img_dimensions"
      t.boolean  "popup",            default: false
      t.integer  "gallery_id"
      t.boolean  "hidden",           default: false
    end
    create_table "semi_static_products", force: :cascade do |t|
      t.string   "name"
      t.text     "description"
      t.string   "color"
      t.string   "height"
      t.string   "depth"
      t.string   "width"
      t.string   "weight"
      t.string   "price"
      t.string   "currency"
      t.integer  "inventory_level", default: 1
      t.integer  "entry_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "semi_static_references", force: :cascade do |t|
      t.string   "title"
      t.text     "body"
      t.text     "quote"
      t.boolean  "show_in_side_bar",  default: false
      t.integer  "position",          default: 0
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.string   "locale",            default: "en"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    # create_table "semi_static_role_users", id: false, force: :cascade do |t|
    #   t.integer "role_id"
    #   t.integer "user_id"
    # end
    # create_table :semi_static_users do |t|
    #  t.string :name
    #  t.string :surname
    #  t.timestamps
    # end
    create_table "semi_static_seos", force: :cascade do |t|
      t.string   "keywords"
      t.string   "title"
      t.string   "description"
      t.boolean  "master",             default: false
      t.string   "locale"
      t.string   "seoable_type"
      t.integer  "seoable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "no_index",           default: false
      t.boolean  "include_in_sitemap", default: true
      t.integer  "changefreq",         default: 0
      t.integer  "priority",           default: 5
    end
    create_table "semi_static_sidebars", force: :cascade do |t|
      t.string   "title"
      t.text     "body"
      t.string   "style_class"
      t.string   "color",           default: "inherit"
      t.string   "bg_color",        default: "inherit"
      t.string   "bg_file_name"
      t.string   "bg_content_type"
      t.integer  "bg_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "partial",         default: ""
    end
    create_table "semi_static_squeezes", force: :cascade do |t|
      t.string   "name"
      t.string   "title"
      t.text     "agreement"
      t.text     "teaser"
      t.text     "instructions"
      t.string   "token"
      t.string   "doc_file_name"
      t.string   "doc_content_type"
      t.integer  "doc_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "form_instructions"
      t.boolean  "company_field",     default: false
      t.boolean  "position_field",    default: false
      t.text     "email_footer"
      t.string   "email_subject"
    end
    create_table "semi_static_subscribers", force: :cascade do |t|
      t.string   "name"
      t.string   "surname"
      t.string   "email"
      t.string   "telephone"
      t.string   "cancel_token"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "locale",       default: "en"
      t.string   "company"
      t.string   "position"
      t.string   "country"
      t.boolean  "unsubscribe",  default: false
      t.integer  "subscriber_category_id"
    end
    create_table "semi_static_tags", force: :cascade do |t|
      t.string   "name"
      t.string   "slug"
      t.boolean  "menu",                      default: false
      t.integer  "position",                  default: 1
      t.string   "predefined_class"
      t.string   "locale",                    default: "en"
      t.integer  "max_entries_on_index_page", default: 3
      t.string   "sidebar_title"
      t.string   "colour",                    default: "inherit"
      t.string   "icon_file_name"
      t.string   "icon_file_type"
      t.integer  "icon_file_size"
      t.boolean  "icon_in_menu",              default: false
      t.boolean  "icon_resize",               default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "banner_id"
      t.string   "partial",                   default: ""
      t.integer  "entry_position",            default: 2
      t.boolean  "side_bar",                  default: true
      t.boolean  "side_bar_news",             default: true
      t.boolean  "side_bar_social",           default: false
      t.boolean  "side_bar_search",           default: false
      t.integer  "newsletter_id"
      t.string   "tag_line"
      t.integer  "side_bar_tag_id"
      t.integer  "layout_select"
      t.boolean  "subscriber",                default: false
      t.integer  "sidebar_id"
      t.integer  "target_tag_id"
      t.string   "target_name"
      t.boolean  "context_url",               default: false
      t.boolean  "admin_only",                default: false
      t.integer  "use_entry_as_index_id"
    end
    create_table :semi_static_subscriber_categories do |t|
      t.string          :name
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial SemiStatic migration is not revertable"
  end
end
