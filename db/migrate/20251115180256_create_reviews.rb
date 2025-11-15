class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.text :content
      t.references :appointment, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :stylist, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
