module Rediff
  class Logger
    def self.string_color(color_code, str)
      "\e[#{color_code}m#{str}\e[0m"
    end

    def self.green_string(str)
      string_color(32, str)
    end

    def self.red_string(str)
      string_color(31, str)
    end

    def self.orange_string(str)
      string_color(33, str)
    end

    def self.blue_string(str)
      string_color(34, str)
    end

    def log_info(str, level: :info, with_time: true)
      return unless ::Rediff.options.verbose?
      log(str, level: level, with_time: with_time)
    end

    def log(str, level: :info, with_time: true)
      str = "[#{::Time.now}]: #{str}" if with_time
      case level.to_sym
      when :success
        puts self.class.green_string(str)
      when :warning
        puts self.class.blue_string(str)
      when :info
        puts self.class.orange_string(str)
      when :error
        puts self.class.red_string(str)
      else
        puts self.class.orange_string(str)
      end
    end
  end
end
