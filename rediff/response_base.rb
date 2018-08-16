module Rediff
  class ResponseBase
    def initialize(response:)
      @response = response
    end

    def data(format = :json)
      case format.to_sym
      when :json
        JSON.parse(body)
      when :raw
        body
      else
        body
      end
    end

    def body
      raise "Please implement [#body] method in class #{self.class}"
    end
  end
end
