class AddLocaleToPhotos < ActiveRecord::Migration
  def up
    add_column :semi_static_photos, :locale, :string
    SemiStatic::Photo.all.each{|p|
      if p.entry
        p.locale = p.entry.locale
      else
        p.locale = SemiStatic::Engine.config.default_locale
      end
      p.save
    }
    SemiStatic::Entry.where('master_entry_id IS NOT NULL').each{|e|
      SemiStatic::Photo.where('entry_id=?', e.master_entry_id).each{|p|
        photo = p.tidy_dup
        photo.locale = e.locale
        e.photos << photo
        e.master_entry_id = nil
        photo.save
        e.save
      }
    }
  end

  def down
    remove_column :semi_static_photos, :locale
  end
end
