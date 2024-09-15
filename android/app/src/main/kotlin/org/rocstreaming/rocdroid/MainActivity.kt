package org.rocstreaming.rocdroid

import AndroidConnector
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.media.AudioManager
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.rocstreaming.connector.AndroidConnectorImpl
import org.rocstreaming.service.SenderReceiverService

private const val LOG_TAG = "[rocdroid.MainActivity]"

class MainActivity: FlutterActivity() {
    private lateinit var senderReceiverService: SenderReceiverService
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AndroidConnector.setUp(flutterEngine.dartExecutor.binaryMessenger,
                               AndroidConnectorImpl())
    }

    private val senderReceiverServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
            senderReceiverService = (binder as SenderReceiverService.LocalBinder).getService()
            
            Log.d(LOG_TAG, "On service connected")

            AndroidConnectorImpl.senderReceiverService = senderReceiverService
        }

        override fun onServiceDisconnected(componentName: ComponentName) {

            Log.d(LOG_TAG, "On service disconnected")

            senderReceiverService.removeListeners()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(LOG_TAG, "Create Main Activity")

        val serviceIntent = Intent(this, SenderReceiverService::class.java)
        bindService(serviceIntent, senderReceiverServiceConnection, BIND_AUTO_CREATE)
    }

    override fun onResume() {
        super.onResume()
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun onDestroy() {
        super.onDestroy()
        unbindService(senderReceiverServiceConnection)
    }
}
