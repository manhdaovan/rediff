module Rediff
  class Diff
    BASE_DIFF_OUTPUT_PATH = __dir__ + '/../output/'

    attr_reader :cmp_objs, :format

    def initialize(*cmp_objs, format:)
      @cmp_objs = cmp_objs
      @format = format
    end

    def export_diff
      set_output_format
      cmp_objs.combination(2).each do |diff_pair|
        export_single_diff(diff_pair.first, diff_pair.last)
      end
    end

    private

    def output_path
      "#{BASE_DIFF_OUTPUT_PATH}#{format}"
    end

    def output_file(identification_str = '')
      "#{output_path}/diff#{identification_str}#{format_ext}"
    end

    def format_ext
      case format
      when :color, :text
        '.txt'
      when :html, :html_simple
        '.html'
      else
        '.txt'
      end
    end

    def set_output_format
      Diffy::Diff.default_format = format
      FileUtils.mkdir_p(output_path)
    end

    def export_single_diff(cmp_obj1, cmp_obj2)
      diffs = Diffy::Diff.new(cmp_obj1, cmp_obj2).to_s
      identification_str = "#{cmp_obj1.object_id}_#{cmp_obj2.object_id}"
      output_file_abs_path = output_file(identification_str)

      if diffs.size < 2
        ::Rediff.logger.log('NO DIFF', level: :success)
        return
      end

      if format == :color
        ::Rediff.logger.log('DIFF START ---------------------------- ')
        puts diffs
        ::Rediff.logger.log('DIFF END   ---------------------------- ')
      else
        write_css(output_file_abs_path) if format.in?([:html, :html_page])
        write_body(output_file_abs_path, diffs)
        ::Rediff.logger.log("Write diff to #{output_file_abs_path} : DONE")
        open_output_file(output_file_abs_path)
      end
    end

    def write_css(output_file_abs_path)
      File.open(output_file_abs_path, 'w+') { |f| f.write('<style>' + Diffy::CSS + '</style>') }
    end

    def write_body(output_file_abs_path, content)
      File.open(output_file_abs_path, 'a+') { |f| f.write(content) }
    end

    def open_output_file(output_file_abs_path)
      `open #{output_file_abs_path}`
    end
  end
end
