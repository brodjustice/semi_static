class AddEmailAndTeleToJobPosting < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_job_postings, :organisation_email, :string
    add_column :semi_static_job_postings, :organisation_telephone, :string
  end
end
