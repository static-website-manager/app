class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.text :password_digest
      t.text :name
      t.text :session_token
      t.text :password_reset_token
      t.boolean :confirmed, default: false, null: false
      t.timestamps null: false
    end
  end
end
