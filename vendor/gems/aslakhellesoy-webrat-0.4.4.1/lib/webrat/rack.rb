require "rack/test"

module Webrat
  class RackSession
    def initialize(context) #:nodoc:
      @session = Rack::Test::Session.new(context.app, "www.example.com")
    end

    def get(url, data = {}, headers = {})
      process_request(:get, url, data, headers)
    end

    def post(url, data = {}, headers = {})
      process_request(:post, url, data, headers)
    end

    def put(url, data = {}, headers = {})
      process_request(:put, url, data, headers)
    end

    def delete(url, data = {}, headers = {})
      process_request(:delete, url, data, headers)
    end

    def response_body
      response.body
    end

    def response_code
      response.status
    end

    def response
      @session.last_response
    end

    def request
      @session.last_request
    end

  protected

    def process_request(http_method, url, data = {}, headers = {})
      headers ||= {}
      data    ||= {}

      params = data.inject({}) { |acc, (k,v)|
        acc.update(k => Rack::Utils.unescape(v))
      }

      env = headers.merge(:params => params, :method => http_method.to_s.upcase)
      @session.request(url, env)
    end
  end
end
