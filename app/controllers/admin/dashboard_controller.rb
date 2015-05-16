class Admin::DashboardController < Admin::BaseController
  def index
    @tasks = ImportTask.where(country_code: params[:locale])
  end
end