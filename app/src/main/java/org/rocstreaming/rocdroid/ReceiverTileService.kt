package org.rocstreaming.rocdroid

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Binder
import android.os.IBinder
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import android.widget.Button
import android.widget.Toast


class ReceiverTileService : TileService() {

    private var senderReceiverService: SenderReceiverService? = null;

    private val senderReceiverServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
            val binder = binder as SenderReceiverService.LocalBinder
            senderReceiverService = binder.getService()

            if ( senderReceiverService!!.isReceiverAlive() ) {
                senderReceiverService!!.stopReceiver()
            } else {
                senderReceiverService!!.startReceiver()
            }
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            senderReceiverService?.removeListeners()
            senderReceiverService = null
        }
    }


    override fun onCreate() {
        Log.i("ROC-TileService", "onCreate: called")

        //Toast.makeText(this.applicationContext, "onCreate", Toast.LENGTH_SHORT).show()
        super.onCreate()
    }

    override fun onStart(intent: Intent?, startId: Int) {
        Log.i("ROC-TileService", "onStart: called")

        super.onStart(intent, startId)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i("ROC-TileService", "onStartCommand: called")

        //Toast.makeText(this.applicationContext, "onStartCommand", Toast.LENGTH_SHORT).show()
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        Log.i("ROC-TileService", "onDestroy: called")

        //Toast.makeText(this.applicationContext, "onDestroy", Toast.LENGTH_SHORT).show()
        super.onDestroy()
    }

    override fun onUnbind(intent: Intent?): Boolean {
        Log.i("ROC-TileService", "onUnbind: called")

        Toast.makeText(this.applicationContext, "onUnbind", Toast.LENGTH_SHORT).show()
        return super.onUnbind(intent)
    }

    override fun onRebind(intent: Intent?) {
        Log.i("ROC-TileService", "onRebind: called")

        //Toast.makeText(this.applicationContext, "onRebind", Toast.LENGTH_SHORT).show()
        super.onRebind(intent)
    }

    override fun onTileAdded() {
        Log.i("ROC-TileService", "onTileAdded: called")

        //Toast.makeText(this.applicationContext, "onTileAdded", Toast.LENGTH_SHORT).show()
        super.onTileAdded()
    }

    override fun onTileRemoved() {
        Log.i("ROC-TileService", "onTileRemoved: called")

        //Toast.makeText(this.applicationContext, "onTileRemoved", Toast.LENGTH_SHORT).show()
        super.onTileRemoved()
    }

    override fun onStartListening() {
        Log.i("ROC-TileService", "onStartListening: called")

        //Toast.makeText(this.applicationContext, "onStartListening", Toast.LENGTH_SHORT).show()
        super.onStartListening()
    }

    override fun onStopListening() {
        Log.i("ROC-TileService", "onStopListening: called")
        //Toast.makeText(this.applicationContext, "onStopListening", Toast.LENGTH_SHORT).show()
        super.onStopListening()
    }

    override fun onClick() {
        Log.i("ROC-TileService", "onClick: click")
        Toast.makeText(this.applicationContext, "onClick", Toast.LENGTH_SHORT).show()
        super.onClick()

        val tile = this.qsTile

        var intent = Intent(this.baseContext, SenderReceiverService::class.java)

        var serviceBinded = this.applicationContext.bindService(intent,senderReceiverServiceConnection,
            BIND_AUTO_CREATE
        )

        if (serviceBinded) {
            if (senderReceiverService != null) {
                if ( senderReceiverService!!.isReceiverAlive() ) {
                    senderReceiverService!!.stopReceiver()
                    tile.state =  Tile.STATE_INACTIVE
                } else {
                    senderReceiverService!!.startReceiver()
                    tile.state =  Tile.STATE_ACTIVE

                }
            }
        }



        tile.updateTile()

    }
}