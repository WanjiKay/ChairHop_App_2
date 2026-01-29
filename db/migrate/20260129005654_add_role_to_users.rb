class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        # Set role to 'stylist' (1) for users who have appointments as stylist
        # All other users remain as 'customer' (0) by default
        execute <<-SQL
          UPDATE users
          SET role = 1
          WHERE id IN (
            SELECT DISTINCT stylist_id
            FROM appointments
            WHERE stylist_id IS NOT NULL
          )
        SQL
      end
    end
  end
end
