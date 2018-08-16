require 'forwardable'
require_relative './response_base'

module Rediff
  class Response < ResponseBase
    extend ::Forwardable

    def_delegators :@response, :body, :code, :uri

    def cookies
      @response.get_fields('set-cookie')
    end

    def data
      super(:json)
    rescue StandardError
      super(:raw)
    end
  end
end
