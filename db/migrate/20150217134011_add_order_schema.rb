class AddOrderSchema < ActiveRecord::Migration
  def change

    create_table :orders do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :ip_address
      t.string  :card_type
      t.date    :card_expires_on
      t.integer :status, :null => false, :limit => 1, default: 1
      t.timestamps
    end

    create_table :order_items do |t|
      t.string :title
      t.integer :quantity, :null => false, :limit => 1, default: 1
      t.timestamps
    end

    create_table :order_transactions do |t|
      t.integer :order_id
      t.string  :action
      t.integer :amount
      t.boolean :success
      t.string  :authorization
      t.string  :message
      t.text    :params
      t.timestamps
    end

    add_money :orders, :amount, currency: { present: false }
    add_money :order_items, :price, currency: { present: false }
    add_reference :orders, :user, index: true
    add_reference :order_items, :order, index: true
    add_reference :order_items, :product, index: true

  end

end
