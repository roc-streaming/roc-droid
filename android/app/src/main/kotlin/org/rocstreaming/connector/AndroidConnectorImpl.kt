package org.rocstreaming.rocdroid

import AndroidConnector
import AndroidReceiverSettings
import AndroidSenderSettings
import FlutterError
import android.Manifest
import android.media.projection.MediaProjection
import android.util.Log
import java.net.NetworkInterface
import org.rocstreaming.rocdroid.MainActivity
import org.rocstreaming.rocdroid.StreamingService

private const val BAD_SEQUENCE_CODE = "rocdroid.BAD_SEQUENCE"
private const val BAD_SEQUENCE_TEXT = "Invalid method invocation sequence"

private const val NO_SERVICE_CODE = "rocdroid.NO_SERVICE"
private const val NO_SERVICE_TEXT = "Lost connection to streaming service"

private const val NO_PROJECTION_CODE = "rocdroid.NO_PROJECTION"
private const val NO_PROJECTION_TEXT = "Media projection wasn't acquired"

private const val NO_PERMISSION_CODE = "rocdroid.NO_PERMISSION"
private const val NO_PERMISSION_TEXT = "Microhpone permission wasn't granted"

private const val LOG_TAG = "rocdroid.AndroidConnectorImpl"

// Implementation of generated interface AndroidConnector, which methods are invoked
// from the dart side.
class AndroidConnectorImpl : AndroidConnector {
    private var projectionAcquired: Boolean = false

    fun getActivity() : MainActivity {
        return MainActivity.instance
    }

    override fun getLocalAddresses(): List<String> {
        try {
            return NetworkInterface.getNetworkInterfaces().toList()
                .flatMap { it.inetAddresses.toList() }
                .filter { !it.isLoopbackAddress && !it.hostAddress.contains(':') }
                .map { it.hostAddress }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Failed to retrieve address list: " + e.toString())
            return emptyList()
        }
    }

    override fun requestNotifications(callback: (Result<Boolean>) -> Unit) {
        Log.i(LOG_TAG, "Requesting POST_NOTIFICATIONS permission")

        getActivity().requestPermission(
            Manifest.permission.POST_NOTIFICATIONS,
            R.string.allow_notifications_title,
            R.string.allow_notifications_message,
            { isGranted: Boolean ->
                if (!isGranted) {
                    Log.w(LOG_TAG, "Permission request failed")
                    callback(Result.success(false))
                    return@requestPermission
                }

                Log.d(LOG_TAG, "Permission request succeeded")
                callback(Result.success(true))
            })
    }

    override fun requestMicrophone(callback: (Result<Boolean>) -> Unit) {
        Log.i(LOG_TAG, "Requesting RECORD_AUDIO permission")

        getActivity().requestPermission(
            Manifest.permission.RECORD_AUDIO,
            R.string.allow_mic_title,
            R.string.allow_mic_message,
            { isGranted: Boolean ->
                if (!isGranted) {
                    Log.w(LOG_TAG, "Permission request failed")
                    callback(Result.success(false))
                    return@requestPermission
                }

                Log.d(LOG_TAG, "Permission request succeeded")
                callback(Result.success(true))
            })
    }

    override fun acquireProjection(callback: (Result<Boolean>) -> Unit) {
        Log.i(LOG_TAG, "Acquiring media projection")

        if (projectionAcquired) {
            Log.e(LOG_TAG, "Unpaired acquireProjection/releaseProjection calls")
            callback(Result.failure(FlutterError(BAD_SEQUENCE_CODE, BAD_SEQUENCE_TEXT)))
            return
        }

        projectionAcquired = true

        // If service isn't started yet, start it and invoke callback when we've connected.
        // If service is already started, invoke callback immediately.
        getActivity().startService({ service: StreamingService ->
            // Ensure that service won't detach projection until releaseProjection().
            service.disableAutoDetach()

            if (service.hasProjection()) {
                Log.d(LOG_TAG, "Projection already acquired")
                callback(Result.success(true))
                return@startService
            }

            getActivity().requestProjection({ projection: MediaProjection? ->
                if (projection == null) {
                    Log.w(LOG_TAG, "Projection request failed")
                    callback(Result.success(false))
                    return@requestProjection
                }

                Log.d(LOG_TAG, "Projection request succeeded")
                service.attachProjection(projection)
                callback(Result.success(true))
            })
        })
    }

    override fun releaseProjection() {
       Log.i(LOG_TAG, "Releasing media projection")

        if (!projectionAcquired) {
            Log.e(LOG_TAG, "Unpaired acquireProjection/releaseProjection calls")
            throw FlutterError(BAD_SEQUENCE_CODE, BAD_SEQUENCE_TEXT)
        }

        projectionAcquired = false

        val service = getActivity().getService()
        if (service == null) {
            return
        }

        // Allow service to detach projection when it's not needed.
        service.enableAutoDetach()
    }

    override fun startReceiver(settings: AndroidReceiverSettings) {
        Log.i(LOG_TAG, "Starting receiver if needed")

        if (!projectionAcquired) {
            Log.e(LOG_TAG, "startReceiver must be called between acquireProjection/releaseProjection")
            throw FlutterError(BAD_SEQUENCE_CODE, BAD_SEQUENCE_TEXT)
        }

        val service = getActivity().getService()
        if (service == null) {
            Log.e(LOG_TAG, "Lost connection to service")
            throw FlutterError(NO_SERVICE_CODE, NO_SERVICE_TEXT)
        }

        if (!service.hasProjection()) {
            Log.e(LOG_TAG, "Lost acquired projection")
            throw FlutterError(NO_PROJECTION_CODE, NO_PROJECTION_TEXT)
        }

        service.startReceiver(settings)
    }

    override fun stopReceiver() {
        Log.i(LOG_TAG, "Stopping receiver if needed")

        val service = getActivity().getService()
        if (service == null) {
            Log.d(LOG_TAG, "Lost connection to service")
            return
        }

        service.stopReceiver()
    }

    override fun isReceiverAlive(): Boolean {
        val service = getActivity().getService()
        if (service == null) {
            return false
        }

        return service.isReceiverAlive()
    }

    override fun startSender(settings: AndroidSenderSettings) {
        Log.i(LOG_TAG, "Starting sender if needed")

        if (!projectionAcquired) {
            Log.e(LOG_TAG, "startSender must be called between acquireProjection/releaseProjection")
            throw FlutterError(BAD_SEQUENCE_CODE, BAD_SEQUENCE_TEXT)
        }

        val service = getActivity().getService()
        if (service == null) {
            Log.e(LOG_TAG, "Lost connection to service")
            throw FlutterError(NO_SERVICE_CODE, NO_SERVICE_TEXT)
        }

        if (!service.hasProjection()) {
            Log.e(LOG_TAG, "Lost acquired projection")
            throw FlutterError(NO_PROJECTION_CODE, NO_PROJECTION_TEXT)
        }

        if (settings.captureType == AndroidCaptureType.CAPTURE_MIC &&
              !getActivity().hasPermission(Manifest.permission.RECORD_AUDIO)) {
            Log.e(LOG_TAG, "Microphone permission must be granted when using CAPTURE_MIC")
            throw FlutterError(NO_PERMISSION_CODE, NO_PERMISSION_TEXT)
        }

        service.startSender(settings)
    }

    override fun stopSender() {
        Log.i(LOG_TAG, "Stopping sender if needed")

        val service = getActivity().getService()
        if (service == null) {
            Log.d(LOG_TAG, "Lost connection to service")
            return
        }

        service.stopSender()
    }

    override fun isSenderAlive(): Boolean {
        val service = getActivity().getService()
        if (service == null) {
            return false
        }

        return service.isSenderAlive()
    }
}
