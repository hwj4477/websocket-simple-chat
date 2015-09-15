
#gem install em-websocket

require 'em-websocket'
require 'json'

def send_connect_msg

    msg = {"user" => "Server", "message" => "Client Connected : total #{@client_count}"}

    puts msg['message']
    
    @channel.push msg.to_json

end

def send_close_msg
   
    msg = {"user" => "Server", "message" => "Client Disconnected : total #{@client_count}"}

    puts msg['message']
    
    @channel.push msg.to_json

end

EM.run {

  @channel = EM::Channel.new

  @client_count = 0;

  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|

    ws.onopen {

        @channel.subscribe{ |msg| ws.send msg}

        @client_count += 1

        send_connect_msg
    }
    ws.onmessage { |msg|
      
        json_msg = JSON.parse(msg)

        puts "#{json_msg['user']} : #{json_msg['message']}"

        @channel.push "#{msg}"

    }
    ws.onclose {
        
        @client_count -= 1

        send_close_msg
    }
    ws.onerror { |e|
      puts "Error: #{e.message}"
    }
  end
}
