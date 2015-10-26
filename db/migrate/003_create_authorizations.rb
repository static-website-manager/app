class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :website, index: true, foreign_key: true, null: false
      t.integer :content_role, null: false
      t.boolean :account_owner, default: false, null: false
      t.boolean :ssh_access, default: false, null: false
      t.boolean :production_branch_access, default: false, null: false
      t.boolean :staging_branch_access, default: false, null: false
      t.boolean :custom_branch_access, default: false, null: false
      t.timestamps null: false
    end
  end
end
