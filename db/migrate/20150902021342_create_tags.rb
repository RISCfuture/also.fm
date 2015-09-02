class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :playlist, null: false
      t.string :name, null: false, limit: 50
    end

    add_foreign_key :tags, :playlists, on_delete: :cascade
    add_index :tags, [:playlist_id, :name], unique: true
  end
end
