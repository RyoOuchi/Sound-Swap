class AddTitleColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :downloads, :title, :string
  end
end
