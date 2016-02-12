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
      elsif error != nil
        status 403
        body error
      else
        status 200
        body JSON.generate({identifier: arguments[:identifier]})
      end
    end

    post '/sources/:identifier/data' do |identifier|
      payload = JSON.parse(params[:payload], :symbolize_names => true)
      error = PayloadAnalyzer.parse(payload, Client.where(identifier: identifier))

      if params[:payload] == nil
        status 400
        body error
      elsif error != nil
        status 403
        body error
      else
        status 200
      end
    end


  end
end
