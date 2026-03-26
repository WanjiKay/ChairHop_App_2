class AddReadAtToConversationMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :conversation_messages, :read_at, :datetime
  end
end
