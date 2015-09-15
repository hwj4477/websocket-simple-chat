package kr.pe.wjhong.websocketclient;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

/**
 * @author wjhong
 * @since 15. 9. 14..
 */
public class ConnectActivity  extends Activity {

    private EditText etName;
    private EditText etRoomID;

    private Button btnConnect;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_connect);

        etName = (EditText) findViewById(R.id.etName);
        etRoomID = (EditText) findViewById(R.id.etRoomID);

        btnConnect = (Button) findViewById(R.id.btnConnect);
        btnConnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if(etName.getText().toString().length() > 0 && etRoomID.getText().toString().length() > 0)
                {
                    Intent intent = new Intent(ConnectActivity.this, MainActivity.class);
                    intent.putExtra("name", etName.getText().toString());
                    intent.putExtra("room_id", etRoomID.getText().toString());

                    startActivity(intent);
                }

            }
        });
    }
}
