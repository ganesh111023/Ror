class CreateFeedback < ActiveRecord::Migration
  def change
    create_table :feedback do |t|
      t.string    :reason,       :limit => 8
      t.string    :name,         :limit => 45
      t.string    :contact,      :limit => 45
      t.string    :contact_type, :limit => 5
      t.text      :comment
      t.timestamps
    end
    add_reference :feedback, :user, index: true
  end
end
