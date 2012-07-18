class ChatMessagesController < ApplicationController
  before_filter :authenticate_user!

  # GET /chat_messages
  # GET /chat_messages.json
  def index
    @chat_messages = ChatMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chat_messages }
    end
  end

  # GET /chat_messages/1
  # GET /chat_messages/1.json
  def show
    @chat_message = ChatMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @chat_message }
    end
  end

  # GET /chat_messages/new
  # GET /chat_messages/new.json
  def new
    @chat_message = ChatMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @chat_message }
    end
  end

  # GET /chat_messages/1/edit
  def edit
    @chat_message = ChatMessage.find(params[:id])
  end

  # POST /chat_messages
  # POST /chat_messages.json
  def create
    @chat_message = ChatMessage.new(params[:chat_message])

    send_message(@chat_message.body)

    respond_to do |format|
      if @chat_message.save
        format.html { redirect_to @chat_message, notice: 'Chat message was successfully created.' }
        format.json { render json: @chat_message, status: :created, location: @chat_message }
      else
        format.html { render action: "new" }
        format.json { render json: @chat_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /chat_messages/1
  # PUT /chat_messages/1.json
  def update
    @chat_message = ChatMessage.find(params[:id])

    respond_to do |format|
      if @chat_message.update_attributes(params[:chat_message])
        format.html { redirect_to @chat_message, notice: 'Chat message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @chat_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chat_messages/1
  # DELETE /chat_messages/1.json
  def destroy
    @chat_message = ChatMessage.find(params[:id])
    @chat_message.destroy

    respond_to do |format|
      format.html { redirect_to chat_messages_url }
      format.json { head :no_content }
    end
  end

  private

  def send_message(msg)
    to = 'audioair@conference.jabber.ridingrails.info/'

    msg = "Audioair is rocking." if !msg
    begin
      RemoteAudioJabberIM.send_message to, msg
    rescue DRb::DRbConnError => e
      puts "The DRb server could not be contacted"
    end

  end
end
