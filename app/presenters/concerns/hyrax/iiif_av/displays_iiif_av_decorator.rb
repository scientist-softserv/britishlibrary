Hyrax::IiifAv::DisplaysIiifAv.module_eval do
  def iiif_viewer?
    (representative_id.present? &&
      representative_presenter.present? &&
      (representative_presenter.video? ||
        representative_presenter.audio? ||
        (representative_presenter.image? && Hyrax.config.iiif_image_server?))) || super
  end
end

