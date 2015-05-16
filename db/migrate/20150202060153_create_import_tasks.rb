class CreateImportTasks < ActiveRecord::Migration
  def change
    create_table :import_tasks do |t|
      t.string  :file_url, :null => false
      t.string  :file_extension, :limit => 4
      t.string  :currency, :limit => 4
      t.integer :import_type, :null => false, :limit => 1, default: 1
      t.integer :job_count, :null => false, default: 0
      t.string  :country_code, :limit => 3

      t.timestamps
    end
    add_reference :import_tasks, :vendor, index: true
  end
end
