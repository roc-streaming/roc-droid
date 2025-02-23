package org.rocstreaming.rocdroid

import AndroidServiceError
import AndroidServiceEvent
import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log

private const val LOG_TAG = "rocdroid.StreamingConnector"

interface StreamingConnectionHandler {
    fun onConnected()
    fun onEvent(event: AndroidServiceEvent)
    fun onError(error: AndroidServiceError)
    fun onDisconnected()
}

class StreamingConnector(val context: Context, val handler: StreamingConnectionHandler) {
    // non-null once successfully connected to server
    // may temporarily become null when connection is lost
    private var service: StreamingService? = null

    fun getService(): StreamingService? {
        return service
    }

    // bind to service if it's running
    fun bindService() {
        if (service != null) {
            return
        }

        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        @Suppress("DEPRECATION")
        val allServices = activityManager.getRunningServices(Integer.MAX_VALUE)

        for (service in allServices) {
            if (service.service.className == StreamingService::class.java.name) {
                Log.d(LOG_TAG, "Found running service, binding")

                val serviceIntent = Intent(context, StreamingService::class.java)
                context.bindService(serviceIntent, serviceHandler, 0)

                return
            }
        }

        Log.d(LOG_TAG, "No running service found")
    }

    // start service if not started yet
    fun startService() {
        if (service != null) {
            return
        }

        Log.d(LOG_TAG, "Starting service")

        val serviceIntent = Intent(context, StreamingService::class.java)
        context.startForegroundService(serviceIntent)
        context.bindService(serviceIntent, serviceHandler, Context.BIND_AUTO_CREATE)
    }

    // unbind service if bound
    fun unbindService() {
        Log.d(LOG_TAG, "Unbinding service")

        context.unbindService(serviceHandler)
        service = null
    }

    // handler for connect & disconnect events
    private val serviceHandler =
        object : ServiceConnection {
            // called when we've successfully connected to the service
            override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
                Log.i(LOG_TAG, "Service connected")

                // remember service reference
                service = (binder as StreamingService.LocalBinder).getService()
                service?.addEventListener(eventHandler)

                handler.onConnected()
            }

            // called when we've lost connectio to service
            override fun onServiceDisconnected(componentName: ComponentName) {
                Log.w(LOG_TAG, "Service disconnected")

                // forget service reference
                service?.removeEventListener(eventHandler)
                service = null

                handler.onDisconnected()

                // (re)start & reconnect
                Log.d(LOG_TAG, "Initiating asynchronous reconnect")
                startService()
            }
        }

    // handler for events produced by streaming service
    private val eventHandler: StreamingEventListener =
        object : StreamingEventListener {
            override fun onEvent(event: AndroidServiceEvent) {
                handler.onEvent(event)
            }

            override fun onError(error: AndroidServiceError) {
                handler.onError(error)
            }
        }
}
