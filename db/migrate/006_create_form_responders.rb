class CreateFormResponders < ActiveRecord::Migration
  def change
    create_table :form_responders do |t|
      t.references :website, index: true, foreign_key: true, null: false
      t.text :branch_name, null: false
      t.text :dataset_pathname, null: false
      t.text :path_id, null: false
      t.boolean :active, default: true, null: false
      t.timestamps null: false
    end
  end
end
