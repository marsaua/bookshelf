class CreateLentBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :lent_books do |t|
      t.references :book, null: false, foreign_key: true
      t.references :lender, null: false, foreign_key: { to_table: :users }
      t.references :borrower, null: true, foreign_key: { to_table: :users }
      t.string :borrower_name
      t.datetime :lent_at
      t.datetime :returned_at
      t.timestamps
    end
  end
end
