package org.rocstreaming.rocdroid

import AndroidServiceError
import AndroidServiceEvent
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log

private const val LOG_TAG = "rocdroid.QuicktileService"

class QuicktileService : TileService() {
    private var isListening = false
    private var pendingStop = false

    // handler for StreamingConnector events
    private val streamingHandler: StreamingConnectionHandler =
        object : StreamingConnectionHandler {
            override fun onConnected() {
                if (pendingStop) {
                    processStop()
                }
                updateTile()
            }

            override fun onEvent(event: AndroidServiceEvent) {
                updateTile()
            }

            override fun onError(error: AndroidServiceError) {
                updateTile()
            }

            override fun onDisconnected() {
                updateTile()
            }
        }

    val streamingConnector = StreamingConnector(this, streamingHandler)

    override fun onCreate() {
        Log.d(LOG_TAG, "Tile service created")

        super.onCreate()

        // bind to service if it's running
        streamingConnector.bindService()
    }

    override fun onTileAdded() {
        Log.d(LOG_TAG, "Tile added")

        super.onTileAdded()

        // start service if it's not running
        streamingConnector.startService()
    }

    override fun onStartListening() {
        Log.d(LOG_TAG, "Tile shown, setting listening to TRUE")

        super.onStartListening()

        // start service if it's not running
        streamingConnector.startService()

        isListening = true
        updateTile()
    }

    override fun onClick() {
        super.onClick()

        if (this.qsTile.state == Tile.STATE_ACTIVE) {
            processStop()
        } else {
            processStart()
        }
    }

    override fun onStopListening() {
        Log.d(LOG_TAG, "Tile hidden, setting listening to FALSE")

        super.onStopListening()

        isListening = false
    }

    override fun onTileRemoved() {
        Log.d(LOG_TAG, "Tile removed")

        super.onTileRemoved()

        isListening = false
    }

    private fun processStart() {
        // For now, when tile is switched on, we just open app.
        // See gh-137.
        Log.d(LOG_TAG, "Tile is switched ON, opening app")

        pendingStop = false

        if (isListening) {
            qsTile.state = Tile.STATE_ACTIVE
            qsTile.updateTile()
        }

        val intent = Intent().apply {
            component = ComponentName(this@QuicktileService, MainActivity::class.java)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE
        )
        startActivityAndCollapse(pendingIntent)
    }

    private fun processStop() {
        if (isListening) {
            qsTile.state = Tile.STATE_INACTIVE
            qsTile.updateTile()
        }

        val service = streamingConnector.getService()
        if (service == null) {
            Log.d(LOG_TAG, "Not connected to streaming service")
            pendingStop = true
            return
        }

        pendingStop = false

        service.stopSender()
        service.stopReceiver()
    }

    private fun updateTile() {
        if (isListening) {
            val service = streamingConnector.getService()
            val isRunning =
                service != null && (service.isReceiverAlive() || service.isSenderAlive())

            if (isRunning) {
                Log.d(LOG_TAG, "Setting tile state to ACTIVE")
                qsTile.state = Tile.STATE_ACTIVE
            } else {
                Log.d(LOG_TAG, "Setting tile state to INACTIVE")
                qsTile.state = Tile.STATE_INACTIVE
            }
            qsTile.updateTile()
        }
    }
}
