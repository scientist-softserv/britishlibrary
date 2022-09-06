# frozen_string_literal: true

module GoogleSearchConsoleHelper
  def verification_code(cname)
    gsc_codes = YAML.load_file('config/google_search_console_verification_codes.yml')
    gsc_codes[cname]
  end

  def render_gsc_head(_host)
    return '' if current_account.cname.blank?
    # rubocop:disable Rails/OutputSafety
    <<-HTML.strip_heredoc.html_safe
      <meta name="google-site-verification" content="#{verification_code current_account.cname}" />
      HTML
    # rubocop:enable Rails/OutputSafety
  end
end
