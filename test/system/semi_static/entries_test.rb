require "application_system_test_case"

module SemiStatic
  class EntriesTest < ApplicationSystemTestCase
    setup do
      @entry = semi_static_entries(:one)
    end

    test "visiting the index" do
      visit entries_url
      assert_selector "h1", text: "Entries"
    end

    test "creating an Entry" do
      visit entries_url
      click_on "New Entry"

      click_on "Create Entry"

      assert_text "Entry was successfully created"
      click_on "Back"
    end

    test "updating an Entry" do
      visit entries_url
      click_on "Edit", match: :first

      click_on "Update Entry"

      assert_text "Entry was successfully updated"
      click_on "Back"
    end

    test "destroying an Entry" do
      visit entries_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Entry was successfully destroyed"
    end
  end
end

