module Api
  module V1

    class ChatMessagesController < ApplicationController
      respond_to :json

      def index
        if params[:lastChatId].present?
          messages = ChatMessage.where("`chat_messages`.id > ?", params[:lastChatId])
        else
          # Return all message posted in last 3 days
          messages  = ChatMessage.where("posted_on >= ?", Time.now - (86400*3))
        end

        render :json=> {:success=>true , :status=> 200, :chat_messages =>  JSON.parse(messages.to_json(:include => :chat_user)) }
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
