module ApplicationHelper
  def title(page_title, a_page_header = nil)
    content_for(:title) { page_title }
    content_for(:page_header) { a_page_header.is_a?(String) ? a_page_header : page_title }
  end

  def active_class(path)
    mapping =  Rails.application.routes.recognize_path(path)
    'active' if mapping[:controller] == controller.controller_path
  end

  def beauty_price(product)
    content_tag :span, class: 'price' do
      product.price.exchange_to('RUB').format(:symbol => content_tag(:span, t('number.currency.format.unit'), class: 'iso')).html_safe
    end
  end

  # Returns html (<span>) with exchanged price based on current locale (fr/admin/products/32)
  # or passed through the options (:locale => :ru)
  # Will be exchanged whether current locale different than :en
  # price #=> #<Money>
  def exch_price(price, options = {})
    h   = {:ru => 'RUB', :en => 'USD', :fr => 'EUR', :de => 'EUR'}
    loc = params[:locale].to_sym
    loc = options[:locale] if options.include?(:locale)
    n   = price
    n   = n.exchange_to(h[loc]) unless options.include?(:no_exchange) || loc == :en
    options[:locale] = h.invert[options[:currency]] if options.include?(:currency)

    if options.include?(:no_html)
      number_to_currency(n, options)
    else
      content_tag :span, class: 'price' do
        number_to_currency(n, options)
      end
    end
  end

  def def_img(p, size = nil)
    if p.primary_image
      image_tag(p.primary_image.image_filename_url(size))
    else
      image_tag "#{size}_default.png"
    end
  end

end
