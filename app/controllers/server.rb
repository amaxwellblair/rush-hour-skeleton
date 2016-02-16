require 'json'
require 'time'

module RushHour
  class Server < Sinatra::Base

    get '/sources/:identifier/urls/:path' do |identifier, path|
      client = Client.find_by(identifier: identifier)
      route = client[:root_url] + '/' + path
      url = client.urls.find_by(route: route)

      url_to_view(url)

    end

    get '/sources/:identifier' do |identifier|
      client = Client.find_by(identifier: identifier)
      client_to_view(client)

    end

    not_found do
      erb :error
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      client = Client.find_by(identifier: identifier)
      event_name = client.event_names.find_by(name: event_name)
      event_to_view(client, event_name)
    end

    post '/sources' do
      arguments = params.each_with_object({}) do |param, hash|
        hash[param[0].to_sym] = param[1]
      end

      error = ClientAnalyzer.parse(arguments)

      index_to_view(arguments, error)

    end

    post '/sources/:identifier/data' do |identifier|
      if params[:payload]
        payload = JSON.parse(params[:payload], :symbolize_names => true)

        error = PayloadAnalyzer.parse(payload, identifier)

        data_to_view(payload, error)

      else
        status 400
        body "Payload not sent"
      end
    end
  end
end
