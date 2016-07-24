class CreateSemiStaticGalleries < ActiveRecord::Migration
  def up
    create_table :semi_static_galleries do |t|
      t.string          :title
      t.string          :sub_title
      t.text            :description
      t.boolean         :public
      t.string          :locale
      t.integer         :position
      t.timestamps
    end
    add_column  :semi_static_photos, :gallery_id, :integer
    add_column  :semi_static_entries, :gallery_id, :integer
    add_column  :semi_static_photos, :hidden, :boolean, :default => false

    SemiStatic::Gallery.reset_column_information
    SemiStatic::Photo.reset_column_information
    SemiStatic::Engine.config.localeDomains.keys.each{|locale|
      l = SemiStatic::Gallery.create(:title => "Default_#{locale}", :public => true, :locale => locale)
      SemiStatic::Photo.locale(locale).each{|p|
        p.gallery = l
        if p.gallery_control == SemiStatic::Photo::GALLERY_SYM[:invisible]
          p.hidden = true
        end
        p.save
      }
    }
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
