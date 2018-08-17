require_relative './cookie'
require_relative './request'
require_relative './response'
require_relative './diff'
require_relative './html_extractor'
require_relative './logger'
require_relative './options'

module Rediff
  class << self
    def logger
      @logger ||= ::Rediff::Logger.new
    end

    def options=(v)
      @options = ::Rediff::Options.new(v)
    end

    def options
      @options ||= ::Rediff::Options.new
    end
  end

  class Rediff
    VALID_OUTPUT_FORMATS = %i[text html html_simple color].freeze
    VALID_REQUEST_METHODS = %i[get post put].freeze
    VALID_ACTIONS = %i[diff login clear_cookies]

    attr_reader :options

    def initialize(**options)
      @options = {
        method: :get,
        format: :color,
        request_params: nil,
        urls: []
      }.merge(options)
      validate_options!
      ::Rediff.options = @options
    end

    def login
      clear_cookies
      options[:urls].each do |url|
        login_get_options = {
          method: :get,
          format: options[:format],
          urls: [url]
        }
        login_page = fetch_responses(login_get_options).first
        login_submit_options = build_login_options(url, login_page)
        fetch_responses(login_submit_options)
      end
    end

    def diff
      responses = fetch_responses
      show_diff(responses)
    end

    def clear_cookies
      logger.log('[START] Clear cookie(s)', level: :success)
      if options[:urls].any? { |url| url == 'all' }
        clear_all_saved_cookies
      else
        clear_selected_saved_cookies
      end
      logger.log('[DONE]  Clear cookie(s)', level: :success)
    end

    private

    def logger
      ::Rediff.logger
    end

    def build_login_options(url, login_page)
      html_extractor = ::Rediff::HtmlExtractor.new(login_page)
      login_submit_options = {
        format: options[:format]
      }

      authenticity_token = html_extractor.extract_auth_token(options[:auth_token_attr], to_query_params: true)
      login_form_action = html_extractor.extract_login_form_action(options[:form_action_attr])
      login_form_method = html_extractor.extract_login_form_method(options[:form_method_attr])
      submit_url = build_submit_url(url, login_form_action)

      login_submit_options[:urls] = [submit_url]
      login_submit_options[:method] = login_form_method.to_sym
      login_submit_options[:request_params] = options[:request_params] + "&" + authenticity_token

      login_submit_options
    end

    def build_submit_url(url, form_action)
      uri = URI.parse(url)
      "#{uri.scheme}://#{uri.host}:#{uri.port}#{form_action}"
    end

    def clear_all_saved_cookies
      ::Rediff::Cookie.delete_all_cookies
      logger.log_verbose("[DONE]  Clear all cookies")
    end

    def clear_selected_saved_cookies
      options[:urls].each do |url|
        ::Rediff::Cookie.new(url).delete_cookie
        logger.log_verbose("[DONE]  Clear cookie for #{url}")
      end
    end

    def fetch_responses(fetch_options = options)
      fetch_options[:urls].each_with_object([]) do |url, resp|
        cookie = ::Rediff::Cookie.new(url)
        request_options = set_cookie_to_options(cookie, init_request_options)

        method_str_upcase = fetch_options[:method].to_s.upcase
        request = ::Rediff::Request.new(url, **request_options)
        logger.log_verbose("[START] #{method_str_upcase} #{url}", level: :success)

        exec_start_time = Time.now
        response = request.send(fetch_options[:method], fetch_options[:request_params])
        exec_time = (Time.now - exec_start_time) * 1000

        logger.log("[DONE]  #{method_str_upcase} #{url} #{response.code} #{exec_time.truncate}ms", level: :success)
        logger.log_verbose("[RESPONSE] PAYLOAD \n #{response.body}", level: :success)

        save_response_cookie(cookie, response)

        resp << response.data
      end
    end

    def save_response_cookie(cookie, response)
      cookie_str = response.cookies&.map { |c| c.split('; ').first }&.join('; ')
      cookie.write_cookie(cookie_str)
      logger.log_verbose("[DONE]  Write cookie for #{response.uri}")
    end

    def init_request_options
      {}
    end

    def set_cookie_to_options(cookie, options)
      cookie_str = cookie.read_cookie
      options[:cookie] = cookie_str if cookie_str.present?
      options
    end

    def show_diff(responses)
      ::Rediff::Diff.new(*responses, format: options[:format]).export_diff
    end

    def validate_options!
      unless VALID_REQUEST_METHODS.include?(options[:method])
        raise "Invalid request method: #{options[:method]}"
      end

      unless VALID_OUTPUT_FORMATS.include?(options[:format])
        raise "Invalid request format: #{@option[:format]}"
      end

      unless VALID_ACTIONS.include?(options[:action])
        raise "Invalid action: #{options[:action]}"
      end

      if options[:method] != :get && options[:request_params].blank?
        raise 'Params is required for non-get method!'
      end

      if options[:action] == :login && options[:request_params].blank?
        raise 'Params is required for login action!'
      end

      raise 'Url(s) is(are) required!' if options[:urls].empty?
    end
  end
end
