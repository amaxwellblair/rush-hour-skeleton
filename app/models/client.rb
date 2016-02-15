class Client < ActiveRecord::Base
  has_many :payloads
  has_many :urls, through: :payloads
  has_many :request_types, through: :payloads
  has_many :user_agents, through: :payloads
  has_many :screen_resolutions, through: :payloads
  has_many :event_names, through: :payloads
  validates :root_url, presence: true
  validates :identifier, presence: true, uniqueness: true
end
