class WorkRedirectController < ApplicationController
  def show
    work = ActiveFedora::Base.find(params[:id])
    redirect_to  polymorphic_path([main_app, work])
  end
end
