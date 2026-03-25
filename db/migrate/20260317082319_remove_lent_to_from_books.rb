# frozen_string_literal: true

class RemoveLentToFromBooks < ActiveRecord::Migration[8.1]
  def change
    remove_column :books, :lent_to_user_id, :integer
    remove_column :books, :lent_to_name, :string
  end
end
