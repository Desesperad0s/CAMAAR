# encoding: utf-8

World(Rack::Test::Methods)

def app
  Rails.application
end

def json_response
  JSON.parse(last_response.body)
rescue JSON::ParserError
  {}
end
