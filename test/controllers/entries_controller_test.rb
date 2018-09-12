module SemiStatic
  class EntriesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
 
    def test_index
      get semi_static_entries_url
    end
  end
end
