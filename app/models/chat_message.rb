class ChatMessage < ActiveRecord::Base
  attr_accessible :body, :chatroom_node, :posted_on, :user_id, :user_node

  belongs_to :chat_user
  profanity_filter :body, :user_node, :method => 'vowels'
end
