class CreateCountriesProducts < ActiveRecord::Migration
  def change
    create_table :countries_products, id: false do |t|
      t.integer :product_id
      t.string :country_code, :limit => 3
    end

    add_index :countries_products, :product_id
    add_index :countries_products, :country_code

  end
end
