$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "semi_static/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "semi_static"
  s.version     = SemiStatic::VERSION
  s.authors     = ["Brod Justice @ Business Landing Ltd"]
  s.email       = ["brod@business-landing.com"]
  s.homepage    = "http://business-landing.com"
  s.summary     = "Basic website builder with cacheing"
  s.description = "Some basic CRM is supported but the main aim is to provide a very fast cached, ie. static, website that works well for desktop and mobile"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.19"
  s.add_dependency "jquery-rails"
  s.add_dependency "haml"
  s.add_dependency "haml-rails"
  s.add_dependency "debugger"
  s.add_dependency "paperclip", "~> 2.7"

  s.add_dependency "truncate_html"

  # For search
  s.add_dependency "elasticsearch", "1.0.4"
  s.add_dependency "elasticsearch-model", "0.1.4"
  s.add_dependency "elasticsearch-rails", "0.1.4"

  s.add_development_dependency "pg"
end
