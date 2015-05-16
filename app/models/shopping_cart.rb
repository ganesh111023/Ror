class ShoppingCart < ActiveRecord::Base
  acts_as_shopping_cart


  # Override with your own tax calculation
  #
  # def taxes
  #   subtotal * 8.3
  # end
  #
  # Or...
  #
  # Override this one with a percentage
  def tax_pct
    0
  end

  #
  # Override with shipping cost calculation
  #
  # def shipping_cost
  #   5
  # end

  def paypal_url(return_url, notify_url, order)

    values = {
        :business   => 'imshenitsky-facilitator@gmail.com',
        :cmd        => '_cart',
        :upload     => 1,
        :return     => return_url + '/?order_id=' + order.id.to_s,
        :invoice    => order.id,
        :notify_url => notify_url,
        :custom     => id,
        :lc         => 'ru_RU'
        # + '/?cart_id=' + id
    }
    shopping_cart_items.each_with_index do |item, index|
      values.merge!({
                        "amount_#{index+1}" => item.price/100,
                        "item_name_#{index+1}" => item.item.friendly_id,
                        "item_number_#{index+1}" => item.id,
                        "quantity_#{index+1}" => item.quantity
                    })
    end
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end

end
