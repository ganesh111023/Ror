class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries, id: false do |t|
      t.string :code, :limit => 3
      t.string :name
    end
  end
end
