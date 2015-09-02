class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.belongs_to :for_user, null: false
      t.belongs_to :from_user

      t.string :url, null: false
      t.string :name, limit: 100
      t.text :description
      t.integer :priority, null: false, limit: 2, default: 0

      t.timestamp :listened_at
      t.timestamps null: false
    end

    add_foreign_key :playlists, :users, column: :for_user_id, on_delete: :cascade
    add_foreign_key :playlists, :users, column: :from_user_id, on_delete: :nullify
    add_index :playlists, [:for_user_id, :url], unique: true
    add_index :playlists, [:for_user_id, :priority]
  end
end
