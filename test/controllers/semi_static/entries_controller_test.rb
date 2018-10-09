require 'test_helper'

module SemiStatic
  class EntriesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
 
    setup do
      @entry = semi_static_entries(:one)
    end

    # def test_index
    #   get semi_static_entries_url
    # end
  end
end
