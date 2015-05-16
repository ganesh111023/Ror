class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_conversion_rates
  before_action :set_i18n_locale_from_params

  def set_i18n_locale_from_params

    I18n.locale = :en # Default locale

    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
      else
        redirect_to root_path, status: :moved_permanently, notice: "#{params[:locale]} translation not available"
      end
    else
      # If an user somehow got the application root without locale, redirect to root with :en locale
      redirect_to root_path, status: :moved_permanently
    end
  end

  # Override it so the locale is automatically set when we use any of the *_url or *_path helper methods in our controller or views
  def default_url_options
    { locale: I18n.locale }
  end

  def set_conversion_rates
    rates = Rails.cache.fetch "money:eu_central_bank_rates", expires_in: 24.hours do
      Money.default_bank.save_rates_to_s
    end
    Money.default_bank.update_rates_from_s rates
  end
end
