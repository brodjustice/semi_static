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
