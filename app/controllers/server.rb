require 'pry'
require 'json'

module RushHour
  class Server < Sinatra::Base

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
