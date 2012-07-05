class MessagesController < ApplicationController

  def send
    to = 'audioair@conference.jabber.ridingrails.info/'

    begin
      RemoteAudioJabberIM.send_message to, "Audioair is rocking."
    rescue DRb::DRbConnError => e
      puts "The DRb server could not be contacted"
    end

  end


  def index
    respond_with Message.all
  end

  def show
    respond_with Message.find(params[:id])
  end

  def create
    respond_with Message.create(params[:message])
  end

  def update
    respond_with Message.update(params[:id], params[:messages])
  end

  def destroy
    respond_with Message.destroy(params[:id])
  end
end

