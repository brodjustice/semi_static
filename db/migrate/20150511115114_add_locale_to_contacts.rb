class AddLocaleToContacts < ActiveRecord::Migration
  def change
    add_column :semi_static_contacts, :locale, :string, :default => SemiStatic::Engine.config.default_locale
    add_column :semi_static_subscribers, :locale, :string, :default => SemiStatic::Engine.config.default_locale
  end
end
