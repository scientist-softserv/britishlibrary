# frozen_string_literal: true

# OVERRIDE of Hyrax 2.9.6 from iiif_helper.rb in the main branch as of 10/06/2021 (commit 8c688a8)
# The `universal_viewer_base_url` and `universal_viewer_config_url` method names were needed,
# but the string inside each is a mix of the code from main, and the current uv src

module Hyrax
  module IiifHelper
    def iiif_viewer_display(work_presenter, locals = {})
      render  iiif_viewer_display_partial(work_presenter),
              locals.merge(presenter: work_presenter)
    end

    def iiif_viewer_display_partial(work_presenter)
      'hyrax/base/iiif_viewers/' + work_presenter.iiif_viewer.to_s
    end
  end
end
