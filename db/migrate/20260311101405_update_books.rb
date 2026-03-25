# frozen_string_literal: true

class UpdateBooks < ActiveRecord::Migration[8.1]
  def change
    remove_column :books, :lent_to_friend, :boolean
    add_column :books, :lent_to_user_id, :integer
    add_column :books, :lent_to_name, :string
    add_column :books, :category, :string
  end
end
