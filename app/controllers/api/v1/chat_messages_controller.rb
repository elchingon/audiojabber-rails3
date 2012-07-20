module Api
  module V1

    class ChatMessagesController < ApplicationController
      respond_to :json

      def index
        if params[:lastChatId].present?
          messages = ChatMessage.where("`chat_messages`.id > ?", params[:lastChatId])
          respond_with messages.to_json(:include => :chat_user)
        else
          messages  = ChatMessage.all
          respond_with messages.to_json(:include => :chat_user)
        end
      end

      def show
        respond_with ChatMessage.find(params[:id])
      end

      def create
        chat_message = ChatMessage.create(params[:chat_message])

        respond_with chat_message
      end

      def update
        respond_with ChatMessage.update(params[:id], params[:chat_messages])
      end

      def destroy
        respond_with ChatMessage.find(params[:id]).destroy()
      end

    end
  end
end
