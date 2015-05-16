json.array! @products do |p|
  json.label truncate(p.title, length: 100)
  json.url product_path(p.friendly_id)
  json.icon p.primary_image.nil? ? asset_path('icon_default.png') : p.primary_image.image_filename_url(:icon)
  json.price exch_price p.price
end