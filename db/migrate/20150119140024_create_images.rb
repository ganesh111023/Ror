class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string  :image_filename
      t.boolean :is_primary, null: false, default: false
      t.timestamps
    end
    # add_index :images, :is_primary
    add_reference :images, :product, index: true
  end
end
