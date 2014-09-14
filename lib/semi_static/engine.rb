require 'devise'
require 'elasticsearch'
require 'elasticsearch/model'
require 'elasticsearch/rails'
require 'cancan'
require 'cancan_namespace'

module SemiStatic
  class Engine < ::Rails::Engine
    require 'haml'
    isolate_namespace SemiStatic
  end
end
