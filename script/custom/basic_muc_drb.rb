#!/usr/bin/env ruby

##
# Full-featured IM client. Organized into a Ruby class.


require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/muc'
require 'yaml'
require 'drb'
require 'rexml/document'
require 'rest_client'

# require 'xmpp4r-simple'

# Encoding patch cus we are using ruby 1.9.3 - FIXME
require 'socket'
class TCPSocket
  def external_encoding
    Encoding::BINARY
  end
end

require 'rexml/source'
class REXML::IOSource
  alias_method :encoding_assign, :encoding=
  def encoding=(value)
    encoding_assign(value) if value
  end
end

begin
  # OpenSSL is optional and can be missing
  require 'openssl'
  class OpenSSL::SSL::SSLSocket
    def external_encoding
      Encoding::BINARY
    end
  end
rescue
end


#Jabber::debug = true

config   = YAML.load_file('script/custom/config.yml')
username = config['from']['jid']
password = config['from']['password']
muc_jid = config['muc']['jid']

#########

class Jabber::JID

  ##
  # Convenience method to generate node@domain

  def to_short_s
    s = []
    s << "#@node@" if @node
    s << @domain
    return s.to_s
  end

end

class AudioJabberIM

  def initialize(username, password, muc_jid, config={}, stop_thread=true)
    @config          = config
    @friends_sent_to = []
    @friends_online = {}
    @mainthread = Thread.current

    login(username, password)

    join_room(muc_jid)

    listen_for_subscription_requests
    listen_for_presence_notifications
    listen_for_messages

    #send_initial_presence

    Thread.stop if stop_thread
  end

  def login(username, password)
    @jid    = Jabber::JID.new(username)
    @client = Jabber::Client.new(@jid)
    @client.connect
    @client.auth(password)
  end

  def logout
    @mainthread.wakeup
    @client.close
  end

  def join_room(muc_jid)

    @room = Jabber::MUC::SimpleMUCClient.new(@client)
    @room.join(Jabber::JID.new(muc_jid + @client.jid.node))
  end

  def send_initial_presence
    @room.add_join_callback do |m|
      msg = Jabber::Message.new(m.to, "Hey, AJ here. What's happening out there?")
      @room.send(msg)
      log('Initial Presence.')
    end
  end

  def listen_for_subscription_requests
    @roster   = Jabber::Roster::Helper.new(@client)

    @roster.add_subscription_request_callback do |item, pres|
      if pres.from.domain == @jid.domain
        log "ACCEPTING AUTHORIZATION REQUEST FROM: " + pres.from.to_s
        @roster.accept_subscription(pres.from)
      end
    end
  end

  def listen_for_messages
    @room.add_message_callback do |m|
      if m.type != :error
        if !@friends_sent_to.include?(m.from) && m.from.resource != @client.jid.node  && !m.from.resource.include?("anonymous-")
        #if @friends_sent_to.empty?
          msg = Jabber::Message.new(m.from, "Welcome to Audioair, " + m.from.resource)
          msg.type = :chat
          @room.send(msg)
          @friends_sent_to << m.from
        end

        case m.body.to_s
          #when 'exit'
          #  msg      = Jabber::Message.new(m.from, "Exiting ...")
          #  msg.type = :chat
          #  @room.send(msg)
          #
          #  logout

          when /\.png/

            puts "Changing to #{m.body}"
            if vcard_config = @config['vcard']
              photo = IO::readlines(m.body.to_s).to_s
              @avatar_hash = Digest::SHA1.hexdigest(photo)

              Thread.new do
                vcard = Jabber::Vcard::IqVcard.new({
                                                       'NICKNAME' => vcard_config['nickname'],
                                                       'FN' => vcard_config['fn'],
                                                       'URL' => vcard_config['url'],
                                                       'PHOTO/TYPE' => 'image/png',
                                                       'PHOTO/BINVAL' => Base64::encode64(photo)
                                                   })
                Jabber::Vcard::Helper::set(@client, vcard)
              end

              presence = Jabber::Presence.new(:chat, "Present with new avatar")
              x = presence.add(REXML::Element.new('x'))
              x.add_namespace 'vcard-temp:x:update'
              x.add(REXML::Element.new('photo')).text = @avatar_hash
              @room.send presence

            end

          else
            # msg      = Jabber::Message.new(m.from, "You said #{m.body} at #{Time.now.utc}")
            #              msg.type = :chat
            #              @room.send(msg)
            if m.from.resource != @client.jid.node  && !m.from.resource.include?("anonymous-")
            #site = RestClient::Resource.new('http://www.audiojabber.com/')
            #site['api/v1/chat_messages'].post :chat_message => { :chatroom_node => @room.room, :user_node => m.from.node, :body =>  m.body.to_s, :posted_on => Time.now.utc }
            end
            puts "RECEIVED: " + m.body.to_s

        end
      else
        log [m.type.to_s, m.body].join(": ")
      end

    end

  end

  ##
  # TODO Do something with the Hash of online friends.

  def listen_for_presence_notifications
    @room.add_presence_callback do |m|
      case m.type
        when nil # status: available
          log "PRESENCE: #{m.from.to_short_s} is online"
          @friends_online[m.from.to_short_s] = true
        when :unavailable
          log "PRESENCE: #{m.from.to_short_s} is offline"
          @friends_online[m.from.to_short_s] = false
      end
    end
  end

  def send_message(to, message)
    log("Sending message to #{to}")
    msg      = Jabber::Message.new(to, message)
    msg.type = :chat
    @room.send(msg)
  end

  def change_color(color_name=:blue)
    if vcard_config = @config['vcard']
      filename = case color_name
                   when :blue
                     'avatar-blue.png'
                   when :red
                     'avatar-red.png'
                 end
      photo = IO::readlines(filename).to_s
      @avatar_hash = Digest::SHA1.hexdigest(photo)

      Thread.new do
        vcard = Jabber::Vcard::IqVcard.new({
                                               'NICKNAME' => vcard_config['nickname'],
                                               'FN' => vcard_config['fn'],
                                               'URL' => vcard_config['url'],
                                               'PHOTO/TYPE' => 'image/png',
                                               'PHOTO/BINVAL' => Base64::encode64(photo)
                                           })
        Jabber::Vcard::Helper::set(@client, vcard)
      end

      presence = Jabber::Presence.new(:chat, "Present with new avatar")
      x = presence.add(REXML::Element.new('x'))
      x.add_namespace 'vcard-temp:x:update'
      x.add(REXML::Element.new('photo')).text = @avatar_hash
      @room.send presence
    end
  end

  def create_user(username, password)

    Thread.new do

      client = Jabber::Client.register(password, { :username => username})
      return client

    end
  end

  def log(message)
    puts(message) if Jabber::debug
  end

end

DRb.start_service("druby://localhost:7777", AudioJabberIM.new(username, password, muc_jid, config, false))
DRb.thread.join