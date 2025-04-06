module SetLocale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    locale = params[:locale]
    return nil unless locale
    I18n.available_locales.map(&:to_s).include?(locale) ? locale.to_sym : nil
  end

  def default_url_options
    { locale: I18n.locale }
  end
end 