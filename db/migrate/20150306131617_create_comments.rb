class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.timestamps
    end
    add_reference :comments, :user, index: true
    add_reference :comments, :product, index: true
  end
end
