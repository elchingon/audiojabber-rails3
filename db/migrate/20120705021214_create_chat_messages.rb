class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :user_id
      t.string :user_node
      t.string :chatroom_node
      t.text :body
      t.datetime :posted_on

      t.timestamps
    end
  end
end
