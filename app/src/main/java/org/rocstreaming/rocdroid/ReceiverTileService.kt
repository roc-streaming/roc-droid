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

private const val LOG_TAG = "[rocdroid.ReceiverTileService]"

class ReceiverTileService : TileService() {

    private var senderReceiverService: SenderReceiverService? = null

    private val senderReceiverServiceConnection = object : ServiceConnection {

        override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
            val binder = binder as SenderReceiverService.LocalBinder
            senderReceiverService = binder.getService()
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            senderReceiverService?.removeListeners()
            senderReceiverService = null
        }
    }


    override fun onCreate() {
        Log.d(LOG_TAG, "Creating Reciver Tile Service")

        var intent = Intent(this.baseContext, SenderReceiverService::class.java)
        this.applicationContext.bindService(intent,senderReceiverServiceConnection, BIND_AUTO_CREATE)

    }

    override fun onStartListening() {
        Log.d(LOG_TAG, "Start listening to Tile")

        if ( senderReceiverService!!.isReceiverAlive() ) {
            this.qsTile.state =  Tile.STATE_ACTIVE
        } else {
            this.qsTile.state =  Tile.STATE_INACTIVE
        }

        this.qsTile.updateTile()
    }

    override fun onClick() {
        Log.d(LOG_TAG, "Tile click event")

        if (senderReceiverService != null) {
            if ( senderReceiverService!!.isReceiverAlive() ) {
                senderReceiverService!!.stopReceiver()
                this.qsTile.state =  Tile.STATE_INACTIVE
            } else {
                senderReceiverService!!.startReceiver()
                this.qsTile.state =  Tile.STATE_ACTIVE

            }
        }

        this.qsTile.updateTile()

    }
}
