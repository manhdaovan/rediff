module Rediff
  class Options
    def initialize(options = {})
      @options = { verbose: false }.merge(options)
    end

    def verbose?
      @options[:verbose]
    end
  end
end
