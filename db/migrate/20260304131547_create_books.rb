# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books, &:timestamps
  end
end
