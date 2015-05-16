class Admin::BaseController < ApplicationController
  before_action :is_admin
  layout 'admin'

  private

  def is_admin
    if !current_user.try(:admin?)
      redirect_to dashboard_path, notice: t('admin_access_denied')
    end
  end
end