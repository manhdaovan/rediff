module Rediff
  module Errors
    class BaseError < StandardError; end
    class GeneralError < BaseError; end
    class InvalidParams < BaseError; end
    class InvalidHtmlFormat < BaseError; end
  end
end
