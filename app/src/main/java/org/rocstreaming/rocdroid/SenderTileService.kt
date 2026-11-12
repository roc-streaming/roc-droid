package org.rocstreaming.rocdroid

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log

private const val LOG_TAG = "[rocdroid.SenderTileService]"

class SenderTileService : TileService() {
    private var senderReceiverService: SenderReceiverService? = null

    private val senderReceiverServiceConnection =
        object : ServiceConnection {
            override fun onServiceConnected(
                componentName: ComponentName,
                binder: IBinder,
            ) {
                senderReceiverService = (binder as SenderReceiverService.LocalBinder).getService()
            }

            override fun onServiceDisconnected(componentName: ComponentName) {
                senderReceiverService?.removeListeners()
                senderReceiverService = null
            }
        }

    override fun onCreate() {
        Log.d(LOG_TAG, "Creating Sender Tile Service")

        val intent = Intent(this.baseContext, SenderReceiverService::class.java)
        this.applicationContext.bindService(intent, senderReceiverServiceConnection, BIND_AUTO_CREATE)
    }

    override fun onStartListening() {
        Log.d(LOG_TAG, "Start listening to Tile")

        if (senderReceiverService?.isSenderAlive() == true) {
            this.qsTile.state = Tile.STATE_ACTIVE
        } else {
            this.qsTile.state = Tile.STATE_INACTIVE
        }

        this.qsTile.updateTile()
    }

    override fun onClick() {
        Log.d(LOG_TAG, "Tile click event")

        senderReceiverService?.let {
            if (it.isSenderAlive()) {
                it.stopSender()
                this.qsTile.state = Tile.STATE_INACTIVE
            } else {
                // For sender, we need to start it from the app since it requires IP config
                // Just open the app to sender tab
                val intent = Intent(this, MainActivity::class.java)
                intent.putExtra("open_sender_tab", true)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                this.qsTile.state = Tile.STATE_ACTIVE
            }
        }

        this.qsTile.updateTile()
    }
}
