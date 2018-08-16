module Rediff
  class Cookie
    BASE_COOKIE_FILE_PATH = __dir__ + '/../cookies/'

    attr_reader :url, :cookie_file

    def self.delete_all_cookies
      Dir["#{BASE_COOKIE_FILE_PATH}/*"].each do |f|
        FileUtils.rm(f)
      end
    end

    def initialize(url)
      @url = url
      @cookie_file = gen_cookie_file_name(url)
    end

    def write_cookie(cookie_str, force: false)
      return if !force && cookie_str.blank?

      File.open(touch_cookie_file, 'w+') do |file|
        file.write(cookie_str)
      end
    end

    def read_cookie
      File.open(touch_cookie_file, 'r', &:read)
    end

    def delete_cookie
      cookie_file_path = build_cookie_file_path
      return unless File.exist?(cookie_file_path)
      FileUtils.rm(cookie_file_path)
    end

    private

    def build_cookie_file_path
      BASE_COOKIE_FILE_PATH + cookie_file
    end

    def touch_cookie_file
      cookie_file_path = build_cookie_file_path
      FileUtils.touch(cookie_file_path)
      cookie_file_path
    end

    def gen_cookie_file_name(url_str)
      uri = URI.parse(url_str)
      "#{uri.scheme}_#{uri.host}_#{uri.port}.txt"
    end
  end
end
