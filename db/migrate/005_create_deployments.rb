class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :website, index: true, foreign_key: true, null: false
      t.text :branch_name, null: false
      t.text :type, null: false
      t.text :settings
      t.boolean :active, default: true, null: false
      t.timestamps null: false
    end
  end
end
