# frozen_string_literal: true

module GoogleTagManagerHelper
  def render_gtm_head(_host)
    return '' if current_account.gtm_id.blank?

    # rubocop:disable Rails/OutputSafety
    <<-HTML.strip_heredoc.html_safe
      <!-- Google Tag Manager -->
      <script>
       (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
       })(window,document,'script','dataLayer', "#{current_account.gtm_id}");
      </script>
     <!-- End Google Tag Manager -->
      HTML
    # rubocop:enable Rails/OutputSafety
  end

  def render_gtm_body(_host)
    # render 'layouts/google/gtm_body'
    return '' if current_account.gtm_id.blank?
    # rubocop:disable Rails/OutputSafety
    <<-HTML.strip_heredoc.html_safe
       <!-- Google Tag Manager (noscript) -->

      <noscript><iframe src='https://www.googletagmanager.com/ns.html?id="#{current_account.gtm_id}"'
                    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>

      <!-- End Google Tag Manager (noscript) -->
      HTML
    # rubocop:enable Rails/OutputSafety
  end

  # BL require their own GTM account in _all_ the repos alongside the tenant GTMs
  # So as above, but using static config item from confg/environments
  def hyku_wide_gtm_id
    gtm_config = Rails.application.config_for(:gtm)
    gtm_config['id']
  end

  def render_bl_gtm_head(_host)
    return '' if hyku_wide_gtm_id.blank?

    # rubocop:disable Rails/OutputSafety
    <<-HTML.strip_heredoc.html_safe
      <!-- Google Tag Manager (whole repo) -->
      <script>
       (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
       })(window,document,'script','dataLayer', "#{hyku_wide_gtm_id}");
      </script>
     <!-- End Google Tag Manager -->
      HTML
    # rubocop:enable Rails/OutputSafety
  end

  def render_bl_gtm_body(_host)
    # render 'layouts/google/gtm_body'
    return '' if hyku_wide_gtm_id.blank?
    # rubocop:disable Rails/OutputSafety
    <<-HTML.strip_heredoc.html_safe
       <!-- Google Tag Manager (noscript) (whole repo) -->

      <noscript><iframe src='https://www.googletagmanager.com/ns.html?id="#{hyku_wide_gtm_id}"'
                    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>

      <!-- End Google Tag Manager (noscript) -->
      HTML
    # rubocop:enable Rails/OutputSafety
  end
end
