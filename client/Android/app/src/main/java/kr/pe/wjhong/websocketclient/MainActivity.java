package kr.pe.wjhong.websocketclient;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.util.ArrayList;

public class MainActivity extends Activity implements View.OnClickListener {

    private Context context;

    private WebSocketClient mWebSocketClient;
    private ArrayList<Message> arrayMessage = new ArrayList<Message>();

    private String strName;
    private String strRoomID;

    private TextView txtStatus;
    private TextView txtUser;
    private EditText etMessage;

    private Button btnReconnect;
    private Button btnSend;

    private ListView listView;

    private ListAdapter adapter;

    private boolean isConnected = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        context = this;

        strName = getIntent().getStringExtra("name");
        strRoomID = getIntent().getStringExtra("room_id");

        txtStatus = (TextView) findViewById(R.id.txtStatus);
        txtUser = (TextView) findViewById(R.id.txtUser);
        etMessage = (EditText) findViewById(R.id.etMessage);

        btnReconnect = (Button) findViewById(R.id.btnReconnect);
        btnSend = (Button) findViewById(R.id.btnSend);

        listView = (ListView) findViewById(R.id.listView);

        btnReconnect.setOnClickListener(this);
        btnSend.setOnClickListener(this);

        adapter = new ListAdapter(context);
        listView.setAdapter(adapter);

        txtUser.setText(strName);

        if(!isConnected)
            connectWebSocket();
    }

    private void connectWebSocket() {
        URI uri = null;

        try {

            String encodedName = URLEncoder.encode(strName, "UTF-8");

            String encodedRoomID = URLEncoder.encode(strRoomID, "UTF-8");

            String urlEncoded = "ws://localhost:8080?room_id=" + encodedRoomID + "&user_name=" + encodedName;

            uri = new URI(urlEncoded);

            Log.d("stn", "uri : " + uri);

        } catch (URISyntaxException e) {

            e.printStackTrace();
            return;
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        mWebSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake serverHandshake) {
                Log.i("Websocket", "Opened");

                isConnected = true;

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        txtStatus.setText("Connected - " + strRoomID);

                    }
                });
            }

            @Override
            public void onMessage(String s) {
                final String message = s;

                try {
                    JSONObject jsonMessage = new JSONObject(message);

                    Message msg = new Message(jsonMessage.getString("user"), jsonMessage.getString("message"));

                    arrayMessage.add(msg);

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {

                            etMessage.setText("");

                            adapter.notifyDataSetChanged();

                            listView.setSelection(arrayMessage.size() - 1);
                        }
                    });

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onClose(int i, String s, boolean b) {
                Log.i("Websocket", "Closed " + s);

                isConnected = false;

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        txtStatus.setText("Disconnected");

                    }
                });
            }

            @Override
            public void onError(Exception e) {
                Log.i("Websocket", "Error " + e.getMessage());
            }
        };
        mWebSocketClient.connect();
    }

    @Override
    public void onClick(View view) {

        switch (view.getId())
        {
            case R.id.btnReconnect:

                break;

            case R.id.btnSend:

                if(etMessage.getText().length() > 0)
                {
                    JSONObject jsonMessage = new JSONObject();
                    try {
                        jsonMessage.put("user", strName);
                        jsonMessage.put("message", etMessage.getText());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    mWebSocketClient.send(jsonMessage.toString());

                }


                break;

            default:

                break;
        }
    }

    @Override
    public void onBackPressed() {

        mWebSocketClient.close();

        isConnected = false;

        super.onBackPressed();
    }

    private class ListAdapter extends ArrayAdapter<String> {

        public ListAdapter(Context context) {
            super(context, 0);
        }

        @Override
        public int getCount() {
            return arrayMessage.size();
        }

        /**
         * @param position
         * @param convertView
         * @param parent
         * @return
         */
        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            View v = convertView;

            Message msg = arrayMessage.get(position);

            if (v == null) {
                LayoutInflater vi = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

                v = vi.inflate(R.layout.message_row, null);
            }

            TextView txtMsgLeft= (TextView) v.findViewById(R.id.txtMsgLeft);
            TextView txtMsgRight= (TextView) v.findViewById(R.id.txtMsgRight);

            if(msg.getUser().equals(strName))
            {
                txtMsgLeft.setText("");
                txtMsgRight.setText(msg.getUser() + " : " + msg.getMessage());
            }
            else
            {
                txtMsgRight.setText("");
                txtMsgLeft.setText(msg.getUser() + " : " + msg.getMessage());
            }

            return v;
        }
    }
}
