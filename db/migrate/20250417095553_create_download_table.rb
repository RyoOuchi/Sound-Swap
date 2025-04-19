class CreateDownloadTable < ActiveRecord::Migration[6.1]
  def change
    create_table :downloads do |t|
      t.string :file_path
      t.integer :user_id
    end
  end
end
