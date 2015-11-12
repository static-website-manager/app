class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.text :pending_email
      t.text :password_digest
      t.text :name
      t.text :email_confirmation_token
      t.text :password_reset_token
      t.text :session_token
      t.boolean :confirmed, default: false, null: false
      t.timestamps null: false
    end

    add_index :users, :email_confirmation_token, unique: true
    add_index :users, :password_reset_token, unique: true
    add_index :users, :session_token, unique: true
  end
end
