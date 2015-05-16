class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :slug
      t.string :model
      t.text :description
      t.text :searchable
      t.timestamps
      t.decimal :exch_rate, precision: 10, scale: 4, :null => false, default: 0
      t.decimal :original_price, precision: 10, scale: 2, :null => false, default: 0
      t.string :original_currency, :limit => 3
      t.integer :quantity, :null => false, default: 1
      t.integer :status, :null => false, :limit => 1, default: 1
      t.boolean :is_featured, :default => false
    end
    add_index     :products, :slug, unique: true
    add_reference :products, :category, index: true
    add_reference :products, :vendor, index: true
    add_money :products, :price, currency: { present: false }
  end
end
