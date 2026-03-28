class AddPublisherLanguagePageCountToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :publisher, :string
    add_column :books, :language, :string
    add_column :books, :page_count, :integer
  end
end
