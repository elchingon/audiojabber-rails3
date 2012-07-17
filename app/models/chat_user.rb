class ChatUser < ActiveRecord::Base
  attr_accessible :avatar_link, :first_name, :last_name, :uid, :user_id, :user_node, :username

  # This is called to handle user verification requests that return response parameters
  def self.create_user_by_params(user_json, user_node)

    username = !user_json.empty? ? user_json.fetch("username") : nil
    if !ChatUser.find_all_by_user_node_and_username(user_node, username)
      @user = ChatUser.new
      @user.user_node = user_node

      if !user_json.empty?
        @user.username = user_json.fetch("username")
        @user.first_name = user_json.fetch("firstName")
        @user.last_name = user_json.fetch("lastName")
        @user.uid = user_json.fetch("fbId")
        @user.avatar_url = user_json.fetch("avatarUrl")
      end

      @user.save
      return @user
    end
  end
end
