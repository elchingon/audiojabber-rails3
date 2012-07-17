module Api
  module V1

    class ChatUsersController < ApplicationController
      respond_to :json

      def index
        respond_with ChatUser.all
      end

      def show
        respond_with ChatUser.find(params[:id])
      end

      def create
        chat_user = ChatUser.create(params[:chat_user])

        respond_with chat_user
      end

      def update
        respond_with ChatUser.update(params[:id], params[:chat_users])
      end

      def destroy
        respond_with ChatUser.find(params[:id]).destroy()
      end

      # POST based function that uses to call existing XMLRPC function on jabber server.
      # This will verify Audioair user profile via Facebook token
      # TODO add Audioair user profile oauth token verification
      def create_new_chat_user

        user_json = nil
        if (params[:mSId].present?)
          if (params[:fbToken].present?)
            site = RestClient::Resource.new(AudiojabberDrb::Application.config.my_app.aa_api_server)
            site['verify-user-fb.html'].post(:fbToken => params[:fbToken], :mSId =>  params[:mSId]) { |response, request, result|

              msg =JSON.parse(response.body)

              if msg.fetch('code') == 200
                user_json = msg.fetch('user')
              else
                render :json=> {:success=>false, :message=>msg.fetch('message') }, :status=> msg.fetch('code')
              end

            }
          end

          #if (!params[:aaToken].empty?)
          #  site = RestClient::Resource.new(AudiojabberDrb::Application.config.my_app.aa_api_server)
          #  site['verify-user-aa.html'].post(:aaToken => params[:aaToken], :mSId =>  params[:mSId]) { |response, request, result|
          #
          #    msg =JSON.parse(response.body)
          #
          #    if msg.fetch('code') == 200
          #      user_json = msg.fetch('user')
          #    else
          #      render :json=> {:success=>false, :message=>msg.fetch('message') }, :status=> msg.fetch('code')
          #    end
          #
          #  }
          #end
        else
          render :json=> {:success=>false, :message=>"Error with Mobile Session Id"}, :status=>401
        end


        if (params[:username].present?)

          site = RestClient::Resource.new(AudiojabberDrb::Application.config.my_app.jabber_server)
          site['chattools/createuser.php'].post(:username => params[:username], :password =>  'password'){|response, request, result|

            @user = ChatUser.new
            @user.user_node = params[:username]
            @user.update_user_params(user_json)  unless user_json.nil?

            if @user.save
              msg =JSON.parse(response.body)
              render :json=> {:success=>true, :message=>msg.fetch('text') }, :status=> response.code
            else
              render :json=> {:success=>false, :message=>'User could not be created' }, :status=> 401
            end
          }

        else
          render :json=> {:success=>false, :message=>"Error with your username"}, :status=>401
        end
      end
    end
  end
end
