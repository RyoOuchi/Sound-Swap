class CreatePostTable < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :post_title
      t.string :description
      t.string :file_path
      t.integer :user_id
      t.timestamps
    end
  end
end
