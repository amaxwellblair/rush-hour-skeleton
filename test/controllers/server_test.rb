require_relative '../test_helper'
require 'pry'

class ServerTest < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def app
    RushHour::Server
  end

  def test_create_new_client_with_valid_attributes
    post '/sources', 'identifier=chickie&rootUrl=www.chickpea.com'

    assert_equal 1, Client.count
    assert_equal 200, last_response.status
    assert_equal "{\"identifier\":\"chickie\"}", last_response.body
  end

  def test_create_new_client_with_no_attributes
    post '/sources', ""

    assert_equal 0, Client.count
    assert_equal 400, last_response.status
    assert_equal "Root url can't be blank, Identifier can't be blank", last_response.body
  end

  def test_cant_create_duplicate_payload
    create_clients(1)

    post '/sources', 'identifier=thing0&rootUrl=www.another_thing.com0'

    assert_equal 1, Client.count
    assert_equal 403, last_response.status
    assert_equal "Identifier has already been taken", last_response.body
  end

  def test_cant_create_unregisted_client
    post '/sources/thing0/data', "payload=#{random_payloads.first.to_json}"

    assert_equal 0, Payload.count
    assert_equal 403, last_response.status
    assert_equal "Client can't be blank", last_response.body
  end

  def test_tries_to_create_duplicate_payload
    create_payloads(1)

    post '/sources/jumpstartlab/data', "payload=#{random_payloads.first.to_json}"

    assert_equal 1, Payload.count
    assert_equal 403, last_response.status
    assert_equal "Composite key has already been taken", last_response.body
  end

  def test_creates_payload_only_with_unique_identifier
    create_unique_client

    post '/sources/jumpstartlab/data', "payload=#{random_payloads.first.to_json}"

    assert_equal 1, Payload.count
    assert_equal 200, last_response.status
  end

  def test_returns_error_if_no_payload_exists
    post '/sources/jumpstartlab/data'

    assert_equal 0, Payload.count
    assert_equal 400, last_response.status
  end

  def test_client_has_not_registered_when_trying_to_view_the_statistics
    get '/sources/jumpstartlab'

    assert_equal 400, last_response.status
  end

  def test_client_has_no_payloads_when_trying_to_view_stats
    create_unique_client
    get '/sources/jumpstartlab'
    assert_equal 400, last_response.status
  end

  def test_specific_url_when_at_client_stats
    create_unique_client
    create_payloads(1)

    get 'sources/jumpstartlab/urls/blog'

    assert_equal 200, last_response.status
  end


  def test_incorrect_url_when_at_client_stats
    create_unique_client
    create_payloads(1)

    get 'sources/jumpstartlab/urls/blo'

    assert_equal 400, last_response.status
  end

end
