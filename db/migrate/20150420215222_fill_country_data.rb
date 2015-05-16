class FillCountryData < ActiveRecord::Migration
  def change
    create_table :checkout_countries, id: false do |t|
      t.string :code, :limit => 3
      t.string :name
    end
    Country.connection.execute(File.read('db/migrate/countries.sql'))
  end
end
