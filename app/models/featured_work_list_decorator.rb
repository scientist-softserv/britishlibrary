# OVERRIDE Hyrax 2.9.0 Use hyrax presenter instead of hyrax presenter
module FeaturedWorkListDecorator
  def work_presenters
    ability = nil
    Hyrax::PresenterFactory.build_for(ids: ids,
      presenter_class: Hyku::WorkShowPresenter,
      presenter_args: ability)
  end
end

::FeaturedWorkList.prepend(FeaturedWorkListDecorator)
