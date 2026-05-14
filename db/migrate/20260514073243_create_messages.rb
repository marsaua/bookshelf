class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :book, null: false, foreign_key: true
      t.text :body
      t.boolean :read

      t.timestamps
    end
  end
end
