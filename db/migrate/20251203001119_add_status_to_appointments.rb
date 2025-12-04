class AddStatusToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :status, :integer, default: 0, null: false

    # Update existing records: if booked, set to 'booked' (1), otherwise 'pending' (0)
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE appointments
          SET status = CASE
            WHEN booked = true THEN 1
            ELSE 0
          END
        SQL
      end
    end
  end
end
