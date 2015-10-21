class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :website, index: true, foreign_key: true, null: false
      t.text :branch_name, null: false
      t.text :host_prefix, null: false
      t.text :response_message
      t.integer :response_status
      t.timestamps null: false
    end
  end
end
