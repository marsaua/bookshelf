# frozen_string_literal: true

class ChangeRatingsValueToNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :ratings, :value, false
  end
end
