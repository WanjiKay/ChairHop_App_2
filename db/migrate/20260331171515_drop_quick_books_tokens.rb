class DropQuickBooksTokens < ActiveRecord::Migration[7.1]
  def change
    drop_table :quick_books_tokens
  end
end
