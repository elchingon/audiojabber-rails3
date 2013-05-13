module Api
  module V1

    class ChatMessagesController < ApplicationController
      respond_to :json

      # =begin apidoc
      # url:: /api/v1/chat_messages
      # method:: GET
      # return:: [JSON] - response Success or Error
      # param:: lastChatId:string - Last Chat ID- If passed, call return only chats posted after this id, otherwise defaults to chats posted in last 4 hours
      # param:: chatUserId:string -  chat user id
      # param:: userNode:string -  chat user node
      # param:: chatroomNode:string -  chat room node
      #
      # output:: json
      # [
      #   { "success":"[true | false]",
      #     "message":"Message.",
      #     "status" : [STATUS_CODE {200|401}]
      #     "chat_messages" : [
      #         {
      #             "body" : CHAT_BODY, "chat_user_id" : AUDIOJABBER RECORD ID, "chatroom_node" : MUC NODE, "created_at": RECORD CREATED TIMESTAMP,
      #             "id": CHAT ID, posted_on": CHAT POSTED TIMESTAMP,"user_id":AUDIOAIR USERID,"user_node": CHATROOM HANDLE,
      #             "chat_user":{"avatar_url": AVATAR_URL,"created_at": USER POSETD TIMESTAMP,"first_name":USER FIRST NAME,"id": AUDIOJABBER ID,"last_name": USER LAST NAME,"uid": OAUTH/ FACEBOOK UID,"user_id": AUDIOAIR USERID,"user_node": CHATROOM HANDLE,"username": USERNAME}
      #         }
      #     ]
      # ]
      # ::output-end::
      #
      #  Method  to return chat_messages in JSON object. If no lastChatId is passed, defaults to chats posted in last 4 hours
      # =end
      def index

        conditions = {}
        {
            :chat_user_id => :chatUserId,
            :user_node => :userNode,
            :chatroom_node => :chatroomNode
        }.each{|k1, k2| conditions[k1] = params[k2] unless params[k2].blank?}

        if params[:lastChatId].present?
          messages = ChatMessage.where("`chat_messages`.id > ?", params[:lastChatId]).where(conditions)
        else
          # Return all message posted in last 4 hours
          messages  = ChatMessage.where("posted_on >= ?", 4.hours.ago).where(conditions).limit(1000)
        end

        render :json=> {:success=>true , :status=> 200, :chat_messages =>  JSON.parse(messages.to_json(:include => :chat_user)) }
      end

      def show
        respond_with ChatMessage.find(params[:id])
      end

      def create
        chat_message = ChatMessage.create(params[:chat_message])
        user = ChatUser.find_chat_user_by_node(params[:chat_message][:user_node])

        if (user.nil?)
          user =  ChatUser.create_user_by_params(nil, params[:chat_message][:user_node])
        end

        chat_message.update_attribute(:chat_user_id, user.id) unless user.nil?

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
