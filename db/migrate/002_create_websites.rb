class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.text :name, null: false
      t.boolean :auto_deploy_production, default: true, null: false
      t.boolean :auto_deploy_staging, default: true, null: false
      t.timestamps null: false
    end
  end
end
