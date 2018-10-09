# Oddly the following rake task would fail due to 
# incorrect namespacing of the seeds.rb classes.
# I don't like this method of doing the database
# migrations anyway, so we have dropped this and
# now use a generator to do the whole install and
# database setup
# 
# desc "Loads the SemiStatic Engine seed data to db"
# namespace :semi_static do
#  namespace :db do
#     task :seed do
#       SemiStatic::Engine.load_seed
#     end
#  end
# end

namespace :'semi_static' do
  desc 'Run SemiStatic engine tests'
  task :test do
    semi_static_engine_root = `bundle show semi_static`
    puts "To run SemiStatic tests run \'rails test\' from the SemiStatic engine home directory: #{semi_static_engine_root}"
  end

  namespace :migration do
    desc 'Run migration to add User table to test database'
    task :'user_table' do
      # Add code to create Devise user model migration
    end
  end
end
