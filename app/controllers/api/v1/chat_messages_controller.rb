module Api
  module V1

    class ChatMessagesController < ApplicationController
      respond_to :json

      def index
        respond_with ChatMessage.all
      end

      def show
        respond_with ChatMessage.find(params[:id])
      end

      def create
        chat_message = ChatMessage.create(params[:chat_message])

        send_message(chat_message.body)

        respond_with chat_message
      end

      def update
        respond_with ChatMessage.update(params[:id], params[:chat_messages])
      end

      def destroy
        respond_with ChatMessage.destroy(params[:id])
      end

      private

      def send_message(msg)
        to = 'audioair@conference.jabber.ridingrails.info/'

        msg = "Audioair is rocking." if !msg

        begin
          RemoteAudioJabberIM.send_message to, "Audioair is rocking."
        rescue DRb::DRbConnError => e
          puts "The DRb server could not be contacted"
        end

      end
    end
  end
end
