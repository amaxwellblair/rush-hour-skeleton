require 'pry'
require 'json'

module RushHour
  class Server < Sinatra::Base

    get '/sources/:identifier' do |identifier|

      if !(client = Client.find_by(identifier: identifier))
        status 400
        @error = "Client has not registered"
        erb :error
      elsif client.payloads.all.empty?
        status 400
        @error = "No payload data submitted for this client"
        erb :error
      else
        @statistics = {
          average_response_time:  client.payloads.average_response_time,
          max_response_time:      client.payloads.max_response_time,
          min_response_time:      client.payloads.min_response_time,
          most_frequent_request:  client.request_types.most_frequent_request,
          list_of_all_verbs:      client.request_types.verbs_used,
          list_of_all_urls:       client.urls.pluck(:route),
          web_browser_breakdown:  client.user_agents.browser_breakdown,
          os_breakdown:           client.user_agents.os_breakdown,
          screen_resolution:      client.screen_resolutions.screen_resolution_breakdown
        }
        erb :index
      end
    end

    not_found do
      erb :error
    end

    post '/sources' do
      arguments = params.each_with_object({}) do |param, hash|
        hash[param[0].to_sym] = param[1]
      end

      error = ClientAnalyzer.parse(arguments)
      if arguments.count != 2
        status 400
        body error
      elsif error
        status 403
        body error
      else
        status 200
        body JSON.generate({identifier: arguments[:identifier]})
      end
    end

    post '/sources/:identifier/data' do |identifier|
      if params[:payload]
        payload = JSON.parse(params[:payload], :symbolize_names => true)

        error = PayloadAnalyzer.parse(payload, identifier)

        if !payload
          status 400
          body "Payload not sent"
        elsif error
          status 403
          body error
        else
          status 200
        end
      else
        status 400
        body "Payload not sent"
      end
    end
  end
end
