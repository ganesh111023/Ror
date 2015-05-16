class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  monetize :price_cents
end
