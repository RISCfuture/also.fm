class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false, limit: 16
      t.string :email
      t.string :crypted_password, null: false

      t.timestamps null: false
    end
  end
end
