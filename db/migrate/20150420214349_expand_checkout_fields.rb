class ExpandCheckoutFields < ActiveRecord::Migration
  def change
    add_column :orders, :address1, :string
    add_column :orders, :address2, :string
    add_column :orders, :city, :string
    add_column :orders, :state, :string
    add_column :orders, :zip, :string
    add_column :orders, :phone, :string
    add_column :orders, :country_code, :string, :limit => 3
  end
end
