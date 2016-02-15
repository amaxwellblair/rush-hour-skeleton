require 'pry'
require 'json'
require 'time'

module RushHour
  class Server < Sinatra::Base

    get '/sources/:identifier/urls/:path' do |identifier, path|
      client = Client.find_by(identifier: identifier)
      route = client[:root_url] + '/' + path
      url = client.urls.find_by(route: route)
      if url
        @statistics = {
          "Max response time" =>              url.max_response_time,
          "Min response time" =>              url.min_response_time,
          "List of response times" =>         url.ranked_response_times,
          "Average response time" =>          url.average_response_time,
          "HTTP verb(s) requested" =>         url.associated_verbs,
          "Three most popular referrers" =>   url.most_popular_referrer(3),
          "Three most popular user agents" => url.most_popular_user_agents(3)
        }

        erb :urls
      else
        status 400
        @error = "The url requested does not exist"
        erb :error
      end
    end

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
        @list_of_events = client.event_names.pluck(:name)
        erb :index, locals: {identifier: identifier}
      end
    end

    not_found do
      erb :error
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      client = Client.find_by(identifier: identifier)
      event_name = client.event_names.find_by(name: event_name)
      # 
      # times = (1..24).each_with_object({}) do |hour, times|
      #    event_name.payloads.pluck(:requested_at).map do |time|
      #    end
      # end
      #
      # times["#{(Time.now - 60*60*hour).strftime("%l")}:00"] = Time.now - (60*60*(24 - hour))

      if event_name
        @statistics = {time: "this is the time"}
        erb :event
      else
        @error = "<a href='/sources/#{identifier}'>Back to home page</a>"
        erb :error
      end
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
