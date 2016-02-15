require 'time'

class EventName < ActiveRecord::Base
  has_many :payloads
  validates :name, presence: true, uniqueness: true

  def self.sort_payloads_by_requests
    self.all.sort_by do |event_name|
      -event_name.payloads.count
    end.map(&:name)
  end

  def payloads_per_hour
    requested_ats = payloads.pluck(:requested_at)
    times = {}
    # require 'pry'; binding.pry
    (0..23).each do |hour|
      requested_ats.each do |requested_at|
        payload_time = Time.parse(requested_at)
        if (Time.now - 60*60*hour) < payload_time  && (Time.now - 60*60*(hour+1)) > payload_time
            times["#{(Time.now - 60*60*hour).strftime("%l")}:00"] += 1
        end
      end
    end
    return times
  end

end
