class UserAgent < ActiveRecord::Base
  has_many :payloads
  validates :browser, presence: true
  validates :os, presence: true
  validates :composite_key, presence: true, uniqueness: true

  def self.browser_breakdown
    self.pluck(:browser)
  end

  def self.os_breakdown
    self.pluck(:os)
  end

end
