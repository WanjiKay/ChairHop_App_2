class DropJwtDenylists < ActiveRecord::Migration[7.1]
  def change
    drop_table :jwt_denylists
  end
end
