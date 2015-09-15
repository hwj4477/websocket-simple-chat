$(document).ready(function() {

    $("#input-nav").hide();

    var ws = null;
 
    var room_id = null;
    var name = null;

    $("#connect-chat").bind("submit", function(event) {
        event.preventDefault();

        room_id = $("#room_id").val();
        name = $("#name").val();

        ws = connect_socket(room_id, name);
    });

    $("#input-chat").bind("submit", function(event) {
        event.preventDefault();

        message = $("#message").val();

        if(message.length > 0)
        {   
            var msg = JSON.stringify({"user": name, "message": message});

            ws.send(msg);

            $("#message").val("");
        }
    });
});

function connect_socket(room_id, name)
{
    ws = new WebSocket("ws://localhost:8080?room_id=" + room_id + "&user_name=" + name);

    ws.onmessage = function(data) {
        
        console.log('received data: ' + data.data);
    
        msg = JSON.parse(data.data);

        $("#name").val(msg.user);

        if(msg.user == name)
        {
             $("#messages").append($("<div align='right';></div>").text(msg.user + " : " + msg.message));
        }
        else
        {
             $("#messages").append($("<div></div>").text(msg.user + " : " + msg.message));
        }

        window.scrollTo(0,document.body.scrollHeight);
    };
                
    ws.onclose = function() {
        console.log("Disconnected");

        $("#connect-chat").show();
        $("#chat-input").hide();

        $("#messages").empty();
    };
                    
    ws.onopen = function() {
        console.log("Connected");

        $("#connect-chat").hide();
        $("#input-nav").show();

    };

    return ws;
}
