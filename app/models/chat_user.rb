class ChatUser < ActiveRecord::Base
  attr_accessible :avatar_link, :first_name, :last_name, :uid, :user_id, :user_node, :username

  # This is called to handle user verification requests that return response parameters
  def self.update_user_params(user_json)

    user_json = JSON.parse(user_json)
    self.username = user_json.fetch("username")
    self.user_node = user_json.fetch("user_node")
    self.first_name = user_json.fetch("firstName")
    self.last_name = user_json.fetch("lastName")
    self.uid = user_json.fetch("fbId")
    self.avatar_url = user_json.fetch("avatarUrl")
    self.save!
  end
end
