class AddChatUserToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :chat_user_id, :integer
  end
end
