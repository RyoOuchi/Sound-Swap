class AddPostidColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :downloads, :uploads_id, :integer
  end
end
