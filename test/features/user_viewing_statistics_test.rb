require_relative '../test_helper'

class UserCanViewStatsTest < Minitest::Test
  include TestHelpers
  include Capybara::DSL
  def test_user_can_view_statistics
    create_unique_client
    create_payloads(1)

    visit "/sources/jumpstartlab"

    within "#statistics" do
      assert page.has_content? "67.0"
    end
  end
end
