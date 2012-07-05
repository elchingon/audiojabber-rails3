class ChatMessage < ActiveRecord::Base
  attr_accessible :body, :chatroom_node, :posted_on, :user_id, :user_node
end
