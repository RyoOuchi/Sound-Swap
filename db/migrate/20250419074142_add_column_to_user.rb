class AddColumnToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :int_array, :integer, array: true, default: []
  end
end
