require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'work_show_presenter').to_s

Hyrax::WorkShowPresenter.class_eval do
    # @return [Boolean] render a IIIF viewer
    # OVERRIDE Hyrax 2.9.6 so the universal viewer button will display as long as any of the attached files are an image
    # not just the if the first file is/was an image
    def iiif_viewer?
      representative_id.present? && members_include_viewable_image?
    end
end
