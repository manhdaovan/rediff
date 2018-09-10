require_relative './diff'

module Rediff
  class FileDiff
    def initialize(*files, format: :html)
      @format = format
      @files = files
      validate_init_params!
    end

    def show_diff
      contents = []
      @files.each do |f|
        file_content = File.open(f).read
        contents << JSON.parse(file_content) rescue file_content
      end

      ::Rediff::Diff.new(*contents, format: @format).export_diff
    end

    private

    def validate_init_params!
      @files.each do |f|
        raise 'File not found' unless File.exist?(f)
      end
    end
  end
end
