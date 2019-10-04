class AddRequiredToAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_agreements, :required, :boolean, :defaut => false
  end
end
