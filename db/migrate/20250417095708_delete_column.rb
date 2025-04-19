class DeleteColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :se_file
  end
end
