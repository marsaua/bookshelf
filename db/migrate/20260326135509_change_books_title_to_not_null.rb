class ChangeBooksTitleToNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :books, :title, false

  end
end
