class AddDurationMinutesToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :duration_minutes, :integer
  end
end
