$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "semi_static/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "semi_static"
  s.version     = SemiStatic::VERSION
  s.authors     = ["Brod Justice @ Business Landing Ltd"]
  s.email       = ["brod@business-landing.com"]
  s.homepage    = "http://quantum-websites.com"
  s.summary     = "Basic website builder with cacheing"
  s.description = "Some basic CRM is supported but the main aim is to provide a very fast cached, ie. static, website that works well for desktop and mobile"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.required_ruby_version = '>= 2.3.0'
  
  # s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.2"
  s.add_dependency "actionpack-page_caching"
  s.add_dependency "jquery-rails"
  s.add_dependency "jquery-ui-rails"
  s.add_dependency "haml"
  s.add_dependency "sass-rails"
  s.add_dependency "haml-rails", ">= 1.0"
  s.add_dependency "paperclip", ">= 6.1.0"
  s.add_dependency "nokogiri"

  # Pagination
  s.add_dependency "kaminari"

  # For the shopping cart, aasm is the state machine
  s.add_dependency "aasm"
  s.add_dependency "money-rails"

  # stripe.com is the only currently supported payment provider
  s.add_dependency "stripe"

  # note: uglifier 3.1.0 breaks the jquery compilation, see this bug:
  # - https://github.com/lautis/uglifier/issues/110
  # s.add_dependency "uglifier", "3.0.4"
  # But now fixed in uglifier 3.2

  s.add_dependency "truncate_html"

  # For search, make sure that the version 7 of elasticsearch server is available.
  s.add_dependency "elasticsearch"
  s.add_dependency "elasticsearch-model"
  s.add_dependency "elasticsearch-rails"

  s.add_development_dependency "pg"
end
