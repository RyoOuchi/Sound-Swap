class AddTableToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :like_num, :integer
  end
end
