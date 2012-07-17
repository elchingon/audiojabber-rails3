class CreateChatUsers < ActiveRecord::Migration
  def change
    create_table :chat_users do |t|
      t.integer :user_id
      t.string :user_node
      t.string :username
      t.string :avatar_url
      t.string :first_name
      t.string :last_name
      t.string :uid

      t.timestamps
    end
  end
end
