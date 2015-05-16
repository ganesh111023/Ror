class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name, :limit => 45, :null => false
      t.decimal :markup_percent, precision: 10, scale: 4, :null => false, default: 0
      t.timestamps
    end
  end
end
