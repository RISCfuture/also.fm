class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.belongs_to :playlist, null: false
      t.string :name, null: false, limit: 50
    end

    add_foreign_key :tags, :playlists, on_delete: :cascade
    add_index :tags, %i[playlist_id name], unique: true
  end
end
