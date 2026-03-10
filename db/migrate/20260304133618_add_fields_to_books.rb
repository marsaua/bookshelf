class AddFieldsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :title, :string
    add_column :books, :author, :string
    add_column :books, :description, :text
    add_column :books, :price, :decimal
    add_reference :books, :user, null: false, foreign_key: true
    add_column :books, :lent_to_friend, :boolean
  end
end
