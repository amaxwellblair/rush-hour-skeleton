module RushHour
  class Server
    helpers do
      def url_statistics(url)
        {
          "Max response time" =>              url.max_response_time,
          "Min response time" =>              url.min_response_time,
          "List of response times" =>         url.ranked_response_times,
          "Average response time" =>          url.average_response_time,
          "HTTP verb(s) requested" =>         url.associated_verbs,
          "Three most popular referrers" =>   url.most_popular_referrer(3),
          "Three most popular user agents" => url.most_popular_user_agents(3)
        }
      end

      def client_statistics(client)
        {
          "Average response time" => client.payloads.average_response_time,
          "Max response time" =>     client.payloads.max_response_time,
          "Min response time" =>     client.payloads.min_response_time,
          "Most frequent request" => client.request_types.most_frequent_request,
          "List of all verbs" =>     client.request_types.verbs_used,
          "Web browser breakdown" => client.user_agents.browser_breakdown,
          "OS breakdown" =>          client.user_agents.os_breakdown,
          "Screen resolution" =>     client.screen_resolutions.screen_resolution_breakdown
        }
      end

      def url_to_view(url)
        if url
          @statistics = url_statistics(url)
          erb :urls
        else
          status 400
          @error = "The url requested does not exist"
          erb :error
        end
      end

      def client_to_view(client)
        if !client
          status 400
          @error = "Client has not registered"
          erb :error
        elsif client.payloads.all.empty?
          status 400
          @error = "No payload data submitted for this client"
          erb :error
        else
          @statistics = client_statistics(client)

          @list_of_urls = client.urls.pluck(:route)
          @list_of_paths = @list_of_urls.map do |url|
            url[/\b\/{1}.+/]
          end
          @list_of_events = client.event_names.pluck(:name)
          erb :index, locals: {identifier: client.identifier}
        end

      end

      def event_to_view(client, event_name)
        if event_name
          @statistics = event_name.payloads_per_hour
          erb :event
        else
          @error = "<a href='/sources/#{client.identifier}'>Back to home page</a>"
          erb :error
        end

      end

      def index_to_view(arguments, error)
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

      def data_to_view(payload, error)
        if !payload
          status 400
          body "Payload not sent"
        elsif error
          status 403
          body error
        else
          status 200
        end
      end
    end
  end
end
