class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string  :name
      t.string  :slug
      t.integer :parent_id,     :null => true
      t.integer :lft,           :null => false
      t.integer :rgt,           :null => false
      t.integer :depth,         :null => false, default: 0
      t.string  :country_code,  :limit => 3
      t.integer :is_gift,       :null => false, :limit => 1, default: 0
    end
    add_index :categories, :slug, unique: true
    add_index :categories, :parent_id
    add_index :categories, :lft
    add_index :categories, :rgt
  end
end
