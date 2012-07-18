SimpleRoles.configure do |config|
  config.valid_roles = [:user, :admin, :editor, :owner]
  strategy :many
end