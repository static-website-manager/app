class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.text :name, null: false
      t.timestamps null: false
    end
  end
end
