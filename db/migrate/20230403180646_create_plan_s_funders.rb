class CreatePlanSFunders < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_s_funders do |t|
      t.string :funder_doi, null: false
      t.string :funder_name, null: false
      t.string :funder_status, null: false
      t.timestamps
    end
    add_index :plan_s_funders, :funder_doi
  end
end
