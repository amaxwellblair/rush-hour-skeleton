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
          "Average response time" => client.payloads.average_response_time,
          "Max response time" =>     client.payloads.max_response_time,
          "Min response time" =>     client.payloads.min_response_time,
          "Most frequent request" => client.request_types.most_frequent_request,
          "List of all verbs" =>     client.request_types.verbs_used,
          "Web browser breakdown" => client.user_agents.browser_breakdown,
          "OS breakdown" =>          client.user_agents.os_breakdown,
          "Screen resolution" =>     client.screen_resolutions.screen_resolution_breakdown
        }

        @list_of_urls = client.urls.pluck(:route)
        @list_of_paths = @list_of_urls.map do |url|
          url[/\b\/{1}.+/]
        end
        erb :index, locals: {identifier: identifier}
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

  get '/sources/:identifier/urls/:path'

  end
end
