class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.text :name, null: false
      t.boolean :auto_create_production_deployment, default: true, null: false
      t.boolean :auto_create_staging_deployment, default: true, null: false
      t.boolean :auto_rebase_staging_on_production_changes, default: true, null: false
      t.timestamps null: false
    end
  end
end
