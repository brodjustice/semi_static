class AddSubjectToSqueezeEmail < ActiveRecord::Migration
  def change
    add_column :semi_static_squeezes, :email_subject, :string
  end
end
