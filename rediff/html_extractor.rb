module Rediff
  class HtmlExtractor
    attr_reader :html_page

    def initialize(html_page)
      @html_page = html_page
    end

    def extract_form
      @extract_form ||= begin
        form_start_index = html_page.index('<form')
        from_end_index = html_page.index('</form>')
        raise 'Form not found' if [form_start_index, from_end_index].any?(&:blank?)

        html_page[form_start_index..(from_end_index + 7)]
      end
    end

    def extract_auth_token(auth_token_attr, to_query_params: false)
      auth_token_attr ||= 'authenticity_token'
      form_html = extract_form
      authenticity_token_attr_index = form_html.index(auth_token_attr)
      raise "name=\"#{auth_token_attr}\" is not found in login form" if authenticity_token_attr_index.blank?

      open_tag_index = authenticity_token_attr_index
      open_char = form_html[authenticity_token_attr_index]
      loop do
        break if open_tag_index.zero?
        break if open_char == '<'
        open_tag_index -= 1
        open_char = form_html[open_tag_index]
      end

      form_html_length = form_html.length
      close_tag_index = authenticity_token_attr_index
      close_char = form_html[authenticity_token_attr_index]
      loop do
        break if close_tag_index > form_html_length
        break if close_char == '>'
        close_tag_index += 1
        close_char = form_html[close_tag_index]
      end

      input_tag = form_html[(open_tag_index + 1)..(close_tag_index - 1)]
      attr = input_tag.split(' ').find { |attribute| attribute.start_with?('value=') }
      raise "name=\"#{auth_token_attr}\" value= is not found in <form ... >" if attr.blank?

      auth_token_value = attr[(attr.index('=') + 1)..-1].tr('"', '')
      return auth_token_value unless to_query_params
      "#{auth_token_attr}=#{auth_token_value}"
    end

    def extract_login_form_action(form_action_attr)
      form_action_attr ||= 'action'
      form_html = extract_form

      form_open_tag_index = form_html.index('<')
      form_close_tag_index = form_html.index('>')
      form_tag = form_html[(form_open_tag_index + 1)..(form_close_tag_index - 1)]

      attr = form_tag.split(' ').find { |attribute| attribute.start_with?(form_action_attr) }
      raise "#{form_action_attr}= is not found in <form ... >" if attr.blank?

      attr[(attr.index('=') + 1)..-1].tr('"', '')
    end

    def extract_login_form_method(form_method_attr)
      form_method_attr ||= 'method'
      form_html = extract_form

      form_open_tag_index = form_html.index('<')
      form_close_tag_index = form_html.index('>')
      form_tag = form_html[(form_open_tag_index + 1)..(form_close_tag_index - 1)]

      attr = form_tag.split(' ').find { |attribute| attribute.start_with?(form_method_attr) }
      raise "#{form_method_attr}= is not found in <form ... >" if attr.blank?

      attr[(attr.index('=') + 1)..-1].tr('"', '')
    end
  end
end
