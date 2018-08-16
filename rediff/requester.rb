require_relative './response'

module Rediff
  class Requester
    attr_reader :url, :uri

    def initialize(url, **options)
      @url = url
      @uri = URI(url)
      default_options = {
        use_ssl: using_ssl?,
        verify_mode: ::OpenSSL::SSL::VERIFY_NONE,
        header: {
          'Origin' => "#{@uri.scheme}://#{@uri.host}",
          'Referer' => "#{@uri.scheme}://#{@uri.host}",
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'
        },
        timeout: 60
      }
      @options = default_options.merge(options)
    end

    def get(params)
      @uri = URI(url + '/?' + params) if params.present?
      req = ::Net::HTTP::Get.new(@uri)
      req = set_header(req)
      req = set_cookie(req)
      request(req, uri)
    end

    def post(params)
      req = ::Net::HTTP::Post.new(uri)
      req = set_form_data(req, params)
      req = set_header(req)
      req = set_cookie(req)
      request(req, uri)
    end

    def put(params)
      req = ::Net::HTTP::Put.new(uri)
      req = set_form_data(req, params)
      req = set_header(req)
      req = set_cookie(req)
      request(req, uri)
    end

    private

    def set_form_data(req, params)
      req.set_form_data(params) if params.is_a?(Hash)

      if params.is_a?(String)
        prs = params.split('&').map do |p|
          equal_char_first_index = p.index('=')
          k = p[0...equal_char_first_index]
          v = p[(equal_char_first_index + 1)..-1]

          [CGI.escapeHTML(k), CGI.escapeHTML(v)]
        end.to_h

        req.set_form_data(prs)
      end

      req
    end

    def using_ssl?
      url.to_s.start_with?('https')
    end

    def set_header(req)
      return req unless @options[:header].instance_of?(Hash)
      @options[:header].each do |k, v|
        req[k] = v
      end
      req
    end

    def set_cookie(req)
      return req unless @options.key?(:cookie)
      req.tap { |r| r.add_field('Cookie', @options[:cookie]) }
    end

    def init_http(uri)
      read_timeout = @options[:timeout] || 300 # Seconds
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = !!@options[:use_ssl]
      http.verify_mode = @options[:verify_mode]
      http.read_timeout = read_timeout
      http
    end

    def request(req, uri)
      http = init_http(uri)
      response = http.start do |rq|
        rq.request(req)
      end

      ::Rediff::Response.new(response: response)
    end
  end
end
