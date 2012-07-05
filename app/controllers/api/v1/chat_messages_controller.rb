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

        respond_with chat_message
      end

      def update
        respond_with ChatMessage.update(params[:id], params[:chat_messages])
      end

      def destroy
        respond_with ChatMessage.find(params[:id]).destroy()
      end

      def create_new_chat_user

        if (!params[:username].empty?)

          site = RestClient::Resource.new('http://jabber.ridingrails.info/')
          site['chattools/createuser.php'].post(:username => params[:username], :password =>  'password'){|response, request, result|

            msg =JSON.parse(response.body)
            render :json=> {:success=>true, :message=>msg.fetch('text') }, :status=> response.code

          }

        else
          render :json=> {:success=>false, :message=>"Error with your username"}, :status=>401
        end
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
