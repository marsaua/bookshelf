# frozen_string_literal: true

class CreateBookRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :book_requests do |t|
      t.references :book, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.integer :status
      t.text :message

      t.timestamps
    end
  end
end
