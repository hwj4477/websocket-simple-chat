# encoding: utf-8

# gem install em-websocket
require 'em-websocket'
require 'json'
require 'cgi'

# ----------------------
# WebSocket Simple Chat 
# ----------------------
#
# Handshake Parameter : room_id, user_name
#
# Message format(json) : {"user" : name, "message" : msg}
#

class ChatUser
    attr_reader :room_id, :channel, :name
    attr_writer :channel, :name

    def initialize(room_id, name)
        @room_id = room_id
        @name = name
    end

end

module Chat

    def set_user_channel(users, user) 
    
        users.each do |key, value|
       
            if value.room_id == user.room_id
                return value.channel
            else
                return EM::Channel.new
            end
        end

        return EM::Channel.new

    end
    
    def send_connect_msg(user)

        msg = {"user" => "Server", "message" => "#{user.name} is connected"}

        puts msg['message']

        user.channel.push msg.to_json
    end

    def send_disconnect_msg(user)

        msg = {"user" => "Server", "message" => "#{user.name} is disconnected"}
        
        puts msg['message']
    
        user.channel.push msg.to_json
    end

end

include Chat

EM.run {

  puts "Start Websocket Server..."

  @chat_users = Hash.new

  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|

    ws.onopen { |handshake|

        room_id = CGI.unescape(handshake.query['room_id'])
        name = CGI.unescape(handshake.query['user_name'])

        user = ChatUser.new(room_id, name)

        user.channel = set_user_channel(@chat_users, user)
       
        user.channel.subscribe{ |msg| ws.send msg }

        @chat_users[ws.object_id] = user

        send_connect_msg(user)
    }
    ws.onmessage { |msg|
      
        json_msg = JSON.parse(msg)

        puts "#{json_msg['user']} : #{json_msg['message']}"

        @chat_users[ws.object_id].channel.push "#{msg}"
    }
    ws.onclose {

        user = @chat_users[ws.object_id]

        user.channel.unsubscribe(ws)

        send_disconnect_msg(user)
       
        @chat_users.delete(ws.object_id)
    }
    ws.onerror { |e|
      puts "Error: #{e.message}"
    }

  end
}

