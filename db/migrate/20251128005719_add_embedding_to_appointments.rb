class AddEmbeddingToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :embedding, :vector, limit: 1536
  end
end
