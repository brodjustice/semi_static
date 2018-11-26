class CreateSemiStaticJobPostings < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_entries, :job_posting_id, :integer
    create_table :semi_static_job_postings do |t|
      t.string		:title
      t.text            :description
      t.string		:employment_type
      t.string		:location
      t.text		:responsibilites
      t.text		:estimated_salary
      t.string		:industry
      t.string		:qualifications
      t.text		:skills

      t.datetime	:date_posted
      t.text		:url
      t.string		:organisation_name
      t.string		:organisation_address
      t.string		:organisation_department
      t.string		:organisation_legal_name
      t.string		:organisation_location

      t.string          :organisation_logo_file_name
      t.integer         :organisation_logo_file_size
      t.string          :organisation_logo_content_type
      t.datetime        :organisation_logo_updated_at

      t.text		:organisation_description
      t.timestamps
    end
  end
end
