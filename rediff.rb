require 'optparse'
require 'active_support/all'
require 'fileutils'
require 'net/http'
require 'uri'
require 'diffy'
require 'cgi'
require 'openssl'

require_relative 'rediff/rediff'
require_relative 'rediff/file_diff'

def print_help
  File.open('./help.txt', 'r') do |f|
    f.each { |line| puts line }
  end
end

options = { input: :request, method: :get, format: :color, request_params: nil, verbose: false }
begin
  OptionParser.new do |opts|
    opts.on('-h', '--help', 'Print help') do |_v|
      print_help
      exit
    end

    opts.on('-i', '--input=INPUT_SOURCE', 'Input source: File or request') do |v|
      options.merge!(input: v.to_sym)
    end

    opts.on('-m', '--method=REQUEST_METHOD', 'Request method') do |v|
      options.merge!(method: v.to_sym)
    end

    opts.on('-p', '--params=PARAMS', 'Request params') do |v|
      options.merge!(request_params: v)
    end

    opts.on('-f', '--format=OUTPUT_FORMAT', 'Diff output format') do |v|
      options.merge!(format: v.to_sym)
    end

    opts.on('--auth-token-attr=HTML_ATTR') do |v|
      options.merge!(auth_token_attr: v)
    end

    opts.on('--form-action-attr=HTML_ATTR') do |v|
      options.merge!(form_action_attr: v)
    end

    opts.on('--form-method-attr=HTML_ATTR') do |v|
      options.merge!(form_method_attr: v)
    end

    opts.on('-v', '--verbose') do |_v|
      options.merge!(verbose: true)
    end
  end.parse!
rescue StandardError => e
  ::Rediff.logger.log(e.message, level: :error, with_time: false)
  print_help
  exit
end

options[:urls] = ARGV[1..-1]
options[:action] = ARGV[0].to_sym

action = ARGV[0]
begin
  if options[:input] == :file
    files = ARGV[1..-1]
    Rediff::FileDiff.new(*files, format: options[:format]).show_diff
  else
    Rediff.logger.log("Options: #{options.inspect}", level: :info)
    rd = Rediff::Rediff.new(**options)
    rd.send(action)
  end
rescue StandardError => e
  ::Rediff.logger.log(e.message, level: :error)
  ::Rediff.logger.log(e.backtrace, level: :error)
  print_help
end
