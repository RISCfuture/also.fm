class AddLikedToPlaylists < ActiveRecord::Migration
  def change
    add_column :playlists, :liked, :boolean, null: false, default: false
  end
end
