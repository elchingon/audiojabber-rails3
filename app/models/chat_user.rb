class ChatUser < ActiveRecord::Base
  attr_accessible :avatar_link, :first_name, :last_name, :uid, :user_id, :user_node, :username

  has_many :chat_messages

  # This is called to handle user verification requests that return response parameters
  def self.create_user_by_params(user_json, user_node)

    username = !user_json.nil? ? user_json.fetch("username") : nil

    users = ChatUser.where(:user_node => user_node).where(:username => username).limit(1)
    if users.empty?
      user = ChatUser.new
      user.user_node = user_node
    else
      user = users.first
    end

    if !user_json.nil?
      user.username = user_json.fetch("username")
      user.user_id = user_json.fetch("id")
      user.first_name = user_json.fetch("firstName")
      user.last_name = user_json.fetch("lastName")
      user.uid = user_json.fetch("fbId")
      user.avatar_url = user_json.fetch("avatarUrl")
    end

    user.save
    user

  end

  def self.find_chat_user_by_node(user_node)

    user = ChatUser.find_by_user_node(user_node)
    user unless user.nil?
  end
end
