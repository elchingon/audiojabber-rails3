class ChatUsersController < ApplicationController
  before_filter :authenticate_user!

  # GET /chat_users
  # GET /chat_users.json
  def index
    @chat_users = ChatUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chat_users }
    end
  end

  # GET /chat_users/1
  # GET /chat_users/1.json
  def show
    @chat_user = ChatUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @chat_user }
    end
  end

  # GET /chat_users/new
  # GET /chat_users/new.json
  def new
    @chat_user = ChatUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @chat_user }
    end
  end

  # GET /chat_users/1/edit
  def edit
    @chat_user = ChatUser.find(params[:id])
  end

  # POST /chat_users
  # POST /chat_users.json
  def create
    @chat_user = ChatUser.new(params[:chat_user])

    respond_to do |format|
      if @chat_user.save
        format.html { redirect_to @chat_user, notice: 'Chat user was successfully created.' }
        format.json { render json: @chat_user, status: :created, location: @chat_user }
      else
        format.html { render action: "new" }
        format.json { render json: @chat_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /chat_users/1
  # PUT /chat_users/1.json
  def update
    @chat_user = ChatUser.find(params[:id])

    respond_to do |format|
      if @chat_user.update_attributes(params[:chat_user])
        format.html { redirect_to @chat_user, notice: 'Chat user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @chat_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chat_users/1
  # DELETE /chat_users/1.json
  def destroy
    @chat_user = ChatUser.find(params[:id])
    @chat_user.destroy

    respond_to do |format|
      format.html { redirect_to chat_users_url }
      format.json { head :no_content }
    end
  end
end
