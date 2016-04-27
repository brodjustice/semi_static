class AddFormInstructionsToSqueeze < ActiveRecord::Migration
  def change
    add_column :semi_static_squeezes, :form_instructions, :text
  end
end
