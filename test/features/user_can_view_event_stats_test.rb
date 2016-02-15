require_relative '../test_helper'

class UserCanEventStatsTest < Minitest::Test
  include TestHelpers
  include Capybara::DSL

  def test_user_can_view_specific_url
    create_unique_client
    create_payloads(1)

    visit "/sources/jumpstartlab/urls/blog"

    within "#url_stats" do
      assert page.has_content? "67"
    end
  end
end
