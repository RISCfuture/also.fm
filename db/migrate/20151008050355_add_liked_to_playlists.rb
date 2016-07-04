class AddLikedToPlaylists < ActiveRecord::Migration[4.2]
  def change
    add_column :playlists, :liked, :boolean, null: false, default: false
  end
end
