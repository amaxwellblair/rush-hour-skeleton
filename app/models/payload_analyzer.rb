require 'pry'
require 'user_agent_parser'

class PayloadAnalyzer

  def self.parse(raw_payload, client = nil)
    user_agent = UserAgentParser.parse(raw_payload[:userAgent])
    os = user_agent.os.to_s
    browser = user_agent.to_s
    resolution = raw_payload[:resolutionWidth] + "x" + raw_payload[:resolutionHeight]
    verb = raw_payload[:requestType]
    referred = raw_payload[:referredBy]
    url = raw_payload[:url]
    ip = raw_payload[:ip]
    eventname = raw_payload[:eventName]
    requested_at = raw_payload[:requestAt]
    responded_in = raw_payload[:respondedIn]
    parameters = raw_payload[:parameters]
    # binding.pry
    composite_key = os + browser + resolution + verb + referred + url + ip + eventname + requested_at.to_s + responded_in.to_s + parameters.join
    root_url = url[/.+\/{1}/]

    payload = Payload.create(requested_at: requested_at, responded_in: responded_in, parameters: parameters, composite_key: composite_key)

    RequestType.find_or_create_by(verb: verb).payloads << payload
    ScreenResolution.find_or_create_by(size: resolution).payloads << payload
    Referred.find_or_create_by(name: referred).payloads << payload
    Ip.find_or_create_by(address: ip).payloads << payload
    Url.find_or_create_by(route: url).payloads << payload
    EventName.find_or_create_by(name: eventname).payloads << payload
    UserAgent.find_or_create_by(os: os, browser: browser, composite_key: (os + browser)).payloads << payload

    if client.nil?
      Client.find_or_create_by(root_url: root_url).payloads << payload
    else
      client << payload
    end
    error = nil

    if payload.errors.any?
      error = payload.errors.full_messages.join(", ")
    end

    return error
  end

end
