class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :website, index: true, foreign_key: true, null: false
      t.integer :role, null: false
      t.boolean :owner, default: false, null: false
      t.timestamps null: false
    end
  end
end
