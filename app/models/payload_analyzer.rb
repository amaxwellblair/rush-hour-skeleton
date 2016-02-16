require 'user_agent_parser'

class PayloadAnalyzer

  def self.parse(raw_payload, client_id = nil)

    payload = Payload.create(requested_at: requested_at(raw_payload), responded_in: responded_in(raw_payload), parameters: parameters(raw_payload), composite_key: composite_key(raw_payload))

    RequestType.find_or_create_by(verb: verb(raw_payload)).payloads << payload
    ScreenResolution.find_or_create_by(size: resolution(raw_payload)).payloads << payload
    Referred.find_or_create_by(name: referred(raw_payload)).payloads << payload
    Ip.find_or_create_by(address: ip(raw_payload)).payloads << payload
    Url.find_or_create_by(route: url(raw_payload)).payloads << payload
    EventName.find_or_create_by(name: eventname(raw_payload)).payloads << payload
    UserAgent.find_or_create_by(os: os(raw_payload), browser: browser(raw_payload), composite_key: (os(raw_payload) + browser(raw_payload))).payloads << payload

    Client.find_or_create_by(identifier: client_id).payloads << payload if client_id

    error = nil

    error = payload.errors.full_messages.join(", ") if payload.errors.any?

    return error
  end

  def self.user_agent(raw_payload)
    UserAgentParser.parse(raw_payload[:userAgent])
  end

  def self.os(raw_payload)
    user_agent(raw_payload).os.to_s
  end

  def self.browser(raw_payload)
    user_agent(raw_payload).to_s
  end

  def self.resolution(raw_payload)
    raw_payload[:resolutionWidth] + "x" + raw_payload[:resolutionHeight]
  end

  def self.verb(raw_payload)
    raw_payload[:requestType]
  end

  def self.referred(raw_payload)
    raw_payload[:referredBy]
  end

  def self.url(raw_payload)
    raw_payload[:url]
  end

  def self.ip(raw_payload)
    raw_payload[:ip]
  end

  def self.eventname(raw_payload)
    raw_payload[:eventName]
  end

  def self.requested_at(raw_payload)
    raw_payload[:requestedAt]
  end

  def self.responded_in(raw_payload)
    raw_payload[:respondedIn]
  end

  def self.parameters(raw_payload)
    raw_payload[:parameters]
  end

  def self.composite_key(raw_payload)
    os(raw_payload) + browser(raw_payload) + resolution(raw_payload) + verb(raw_payload)+ referred(raw_payload) + url(raw_payload) + ip(raw_payload) + eventname(raw_payload) + requested_at(raw_payload).to_s + responded_in(raw_payload).to_s + parameters(raw_payload).join
  end
end
