class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.text :name, null: false
      t.text :stripe_customer_token, null: false
      t.text :stripe_subscription_token, null: false
      t.integer :subscription_plan, null: false
      t.integer :subscription_status, null: false
      t.boolean :yearly_billing, default: false, null: false
      t.boolean :auto_rebase_staging_on_production_changes, default: true, null: false
      t.timestamps null: false
    end
  end
end
