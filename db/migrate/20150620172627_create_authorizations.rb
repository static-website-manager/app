class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer :role, default: 0, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.references :website, index: true, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
