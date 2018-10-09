require 'test_helper'

class SemiStaticTest < ActiveSupport::TestCase
  # First we need to see if their is a Devise user model in
  # the test database and if not create it. This is because the 
  # SemiStatic engine does not create the Devise user model
  # migration itself, rather it is generated by the main app
  unless ActiveRecord::Base.connection.data_source_exists? 'semi_static_users'
    
  end

  test "truth" do
    assert_kind_of Module, SemiStatic
  end
end
