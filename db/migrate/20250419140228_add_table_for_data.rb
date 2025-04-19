class AddTableForData < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :file_data, :binary
  end
end
