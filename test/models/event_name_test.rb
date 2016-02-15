require_relative '../test_helper'

class EventNameTest < Minitest::Test
  include TestHelpers

  def test_it_orders_the_payloads_from_most_received_to_least
    create_payloads(4)
    assert_equal ["socialLogin", "ChickenLogin"], EventName.sort_payloads_by_requests
  end

  def test_payloads_per_hour
    create_payloads(5)
    event_name = EventName.all[1]
    times = event_name.payloads_per_hour
    time_loads.each do |key, value|
      assert_equal times[key], value
    end

  end

  def time_loads
    {
      "#{(Time.now - 60*60*(13+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(13)).strftime("%l%p")}" => 0,
      "#{(Time.now - 60*60*(20+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(20)).strftime("%l%p")}" => 1,
      "#{(Time.now - 60*60*(3+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(3)).strftime("%l%p")}" => 1,
      "#{(Time.now - 60*60*(10+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(10)).strftime("%l%p")}" => 1,
      "#{(Time.now - 60*60*(18+1)).strftime("%l%p")+"-"+(Time.now - 60*60*(18)).strftime("%l%p")}" => 1
    }
  end

end
