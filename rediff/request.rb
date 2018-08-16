require_relative './requester'

module Rediff
  class Request
    attr_reader :url

    def initialize(url, **options)
      @requester = ::Rediff::Requester.new(url, **options)
    end

    def get(params)
      @requester.get(params)
    end

    def post(params)
      @requester.post(params)
    end

    def put(params)
      @requester.put(params)
    end
  end
end
