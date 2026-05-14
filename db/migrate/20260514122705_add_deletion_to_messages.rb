class AddDeletionToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :deleted_by_sender, :boolean, default: false, null: false
    add_column :messages, :deleted_by_receiver, :boolean, default: false, null: false
  end
end
