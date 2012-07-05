require 'drb'
DRb.start_service
RemoteAudioJabberIM = DRbObject.new_with_uri "druby://localhost:7777"
