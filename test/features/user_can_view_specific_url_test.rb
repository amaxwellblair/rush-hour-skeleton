require_relative '../test_helper'

class UserCanViewEventStatsTest < Minitest::Test
  include TestHelpers
  include Capybara::DSL

  def test_user_can_view_event_stats
    create_payloads(1)

    visit "/sources/jumpstartlab/events/ChickenLogin"

    within "#event_stats" do
      assert page.has_content? "#{(Time.now - 60*60*(13+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(13)).strftime("%l%p")}: 1"
    end
  end
end
