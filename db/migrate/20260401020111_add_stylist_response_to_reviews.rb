class AddStylistResponseToReviews < ActiveRecord::Migration[7.1]
  def change
    add_column :reviews, :stylist_response, :text
    add_column :reviews, :stylist_responded_at, :datetime
  end
end
