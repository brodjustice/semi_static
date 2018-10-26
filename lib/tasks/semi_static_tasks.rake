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

  desc 'Create non digested assets in public without fingerprints'
  task :non_digested_assets do

    pre_compiled_assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))

    # In development mode we don't have usually have precompiled digested assets
    if Rails.env.development?
      puts 'WARNING: Non digested assets are normally not required in development mode'
    end
    if pre_compiled_assets.blank?
      puts 'WARNING: No assets found, have you forgot to precompile them?'
    end
    
    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    pre_compiled_assets.each do |file|
      next if File.directory?(file) || file !~ regex
      source = file.split('/')
      source.push(source.pop.gsub(regex, '.'))
      non_digested = File.join(source)
      FileUtils.symlink(file, non_digested, :force => true)
    end
  end
end
