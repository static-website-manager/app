class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user, index: true, foreign_key: true
      t.text :public_key, null: false
      t.timestamps null: false
    end
  end
end
