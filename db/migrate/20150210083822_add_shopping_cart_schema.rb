class AddShoppingCartSchema < ActiveRecord::Migration
  def change
    create_table :shopping_carts do |t|
      t.timestamps
    end
    create_table :shopping_cart_items do |t|
      t.shopping_cart_item_fields
      t.timestamps
    end
  end
end