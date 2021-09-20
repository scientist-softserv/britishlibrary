class AddParentIdAndSettingsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :parent, foreign_key: { to_table: :accounts }
    add_column :accounts, :settings, :jsonb, default: {}
    add_index  :accounts, :settings, using: :gin
  end
end
