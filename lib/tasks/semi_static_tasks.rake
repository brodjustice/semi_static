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

  desc 'Create public non digested assets without fingerprints, eg: rails semi_static:non_digested[images]'
  task 'non_digested', ['asset_type'] do |task, args|

    if args['asset_type'].present?
      link_assets(args['asset_type'])
    else
      puts 'ERROR: no asset type given. Typical assets types are passed thus: rails semi_static:non_digested[images]'
    end
  end


  def link_assets(assets_type_by_directory_name)
    # In development mode we don't have usually have precompiled digested assets
    if Rails.env.development?
      puts 'WARNING: Non digested assets are normally not required in development mode'
    end

    unless File.directory?(File.join(Rails.root, "public/assets"))
      puts 'ERROR: cannot find precompiled assets directory, have you precompiled your assets?'
      return
    end

    if Dir.glob(File.join(Rails.root, "app/assets/#{assets_type_by_directory_name}")).first
      Dir.chdir(Dir.glob(File.join(Rails.root, "app/assets/#{assets_type_by_directory_name}")).first)
    else
      puts "ERROR: cannot find assets directory for #{assets_type_by_directory_name}"
      return
    end

    non_digested_assets = Dir.glob("**/*")

    if non_digested_assets.blank?
      puts 'WARNING: No assets found'
    end
    
    non_digested_assets.each do |file|
      next if File.directory?(file)

      FileUtils.symlink(File.join(Rails.root, "app/assets/#{assets_type_by_directory_name}/#{file}"), File.join(Rails.root, "public/assets/", file),  :force => true)
    end
  end
end
