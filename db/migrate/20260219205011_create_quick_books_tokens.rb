class CreateQuickBooksTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :quick_books_tokens do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :access_token, null: false
      t.text :refresh_token, null: false
      t.string :realm_id, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
