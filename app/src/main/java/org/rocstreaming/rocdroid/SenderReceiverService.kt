package org.rocstreaming.rocdroid

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import kotlinx.coroutines.runBlocking
import org.rocstreaming.roctoolkit.ChannelSet
import org.rocstreaming.roctoolkit.ClockSource
import org.rocstreaming.roctoolkit.Endpoint
import org.rocstreaming.roctoolkit.FrameEncoding
import org.rocstreaming.roctoolkit.Interface
import org.rocstreaming.roctoolkit.Protocol
import org.rocstreaming.roctoolkit.RocContext
import org.rocstreaming.roctoolkit.RocReceiver
import org.rocstreaming.roctoolkit.RocReceiverConfig
import org.rocstreaming.roctoolkit.RocSender
import org.rocstreaming.roctoolkit.RocSenderConfig
import org.rocstreaming.roctoolkit.Slot

private const val SAMPLE_RATE = 44100
private const val BUFFER_SIZE = 100

private const val CHANNEL_ID = "SenderReceiverService"
private const val NOTIFICATION_ID = 1

private const val BROADCAST_STOP_SENDER_ACTION =
    "org.rocstreaming.rocdroid.NotificationSenderStopAction"
private const val BROADCAST_STOP_RECEIVER_ACTION =
    "org.rocstreaming.rocdroid.NotificationReceiverStopAction"

private const val LOG_TAG = "[rocdroid.SenderReceiverService]"

/**
 * The foreground service types needed for what is currently running, or 0 if none is.
 *
 * Capturing the microphone is deliberately absent: the service does not declare that type.
 */
@SuppressLint("InlinedApi") // Plain ints; ServiceCompat ignores them where they don't exist.
internal fun foregroundServiceTypes(
    receiving: Boolean,
    capturingPlayback: Boolean,
): Int {
    var types = 0
    if (receiving) types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
    if (capturingPlayback) types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
    return types
}

class SenderReceiverService : Service() {
    private var receiverThread: Thread? = null
    private var senderThread: Thread? = null
    private var receiverChanged: ((Boolean) -> Unit)? = null
    private var senderChanged: ((Boolean) -> Unit)? = null
    private var senderErrorCallback: ((String) -> Unit)? = null
    private var senderStatusChanged: ((StreamStatus) -> Unit)? = null
    private var receiverStatusChanged: ((StreamStatus) -> Unit)? = null

    @Volatile private var receiverAudioTrack: AudioTrack? = null
    private var isForegroundRunning = false

    // True from the moment the user allows capturing other apps until that sender stops.
    @Volatile private var senderCapturesPlayback = false

    private val notificationStopActionReceiver: BroadcastReceiver =
        object : BroadcastReceiver() {
            override fun onReceive(
                context: Context,
                intent: Intent,
            ) {
                when (intent.action) {
                    BROADCAST_STOP_SENDER_ACTION -> stopSender()
                    BROADCAST_STOP_RECEIVER_ACTION -> stopReceiver()
                }
            }
        }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): SenderReceiverService = this@SenderReceiverService
    }

    override fun onBind(intent: Intent): IBinder {
        Log.d(LOG_TAG, "Bind Service")

        return binder
    }

    override fun onCreate() {
        Log.d(LOG_TAG, "Creating Sender/Receiver Service")

        createNotificationChannel()
        ContextCompat.registerReceiver(
            this,
            notificationStopActionReceiver,
            IntentFilter().apply {
                addAction(BROADCAST_STOP_SENDER_ACTION)
                addAction(BROADCAST_STOP_RECEIVER_ACTION)
            },
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
    }

    override fun onDestroy() {
        Log.d(LOG_TAG, "Destroying Sender/Receiver Service")

        super.onDestroy()
        unregisterReceiver(notificationStopActionReceiver)
    }

    private fun createNotificationChannel() {
        Log.d(LOG_TAG, "Creating Notification Channel")

        val channel =
            NotificationChannel(
                CHANNEL_ID,
                getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_LOW,
            )
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(channel)
    }

    internal fun buildNotification(
        sending: Boolean,
        receiving: Boolean,
    ): Notification {
        Log.d(
            LOG_TAG,
            String.format(
                "Building Notification for %s %s",
                if (sending) "Sender" else "",
                if (receiving) "Receiver" else "",
            ),
        )

        val mainActivityIntent = Intent(this, MainActivity::class.java)
        val pendingMainActivityIntent =
            PendingIntent.getActivity(
                this,
                0,
                mainActivityIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        // Name this app: the receiver is not exported, and Android 14+ does not deliver a
        // broadcast without a target package to it.
        val stopSenderIntent = Intent(BROADCAST_STOP_SENDER_ACTION).setPackage(packageName)
        val pendingStopSenderIntent =
            PendingIntent.getBroadcast(
                this@SenderReceiverService,
                0,
                stopSenderIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        val stopReceiverIntent = Intent(BROADCAST_STOP_RECEIVER_ACTION).setPackage(packageName)
        val pendingStopReceiverIntent =
            PendingIntent.getBroadcast(
                this@SenderReceiverService,
                0,
                stopReceiverIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        val stopSenderAction =
            Notification.Action.Builder(
                Icon.createWithResource(this@SenderReceiverService, R.drawable.ic_stop),
                getString(R.string.notification_stop_sender_action),
                pendingStopSenderIntent,
            ).build()
        val stopReceiverAction =
            Notification.Action.Builder(
                Icon.createWithResource(this@SenderReceiverService, R.drawable.ic_stop),
                getString(R.string.notification_stop_receiver_action),
                pendingStopReceiverIntent,
            ).build()
        return Notification.Builder(this, CHANNEL_ID).apply {
            setContentTitle(getString(R.string.notification_title))
            setContentText(getContentText(sending, receiving))
            setSmallIcon(R.drawable.ic_notification)
            setVisibility(Notification.VISIBILITY_PUBLIC)
            setContentIntent(pendingMainActivityIntent)
            if (sending) {
                addAction(stopSenderAction)
            }
            if (receiving) {
                addAction(stopReceiverAction)
            }
        }.build()
    }

    /**
     * Makes the foreground state and its notification match the streams that are running.
     *
     * Android 14+ checks every foreground service type the service asks for against what the
     * app is allowed to do at that moment, so this asks only for the types in use right now
     * instead of everything the manifest declares.
     */
    @Synchronized
    private fun updateForeground(
        sending: Boolean,
        receiving: Boolean,
    ) {
        Log.d(
            LOG_TAG,
            String.format(
                "Updating Foreground State for %s %s",
                if (sending) "Sender" else "",
                if (receiving) "Receiver" else "",
            ),
        )

        val types =
            foregroundServiceTypes(
                receiving = receiving,
                capturingPlayback = sending && senderCapturesPlayback,
            )

        if (types == 0) {
            if (isForegroundRunning) {
                stopForegroundService()
            }
            return
        }

        isForegroundRunning = true
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(sending, receiving),
            types,
        )
    }

    private fun getContentText(
        sending: Boolean,
        receiving: Boolean,
    ): String {
        Log.d(LOG_TAG, "Getting Notification Content Text")

        if (sending && receiving) {
            return getString(R.string.notification_sender_and_receiver_running)
        }
        if (receiving) {
            return getString(R.string.notification_receiver_running)
        }
        if (sending) {
            return getString(R.string.notification_sender_running)
        }
        return getString(R.string.notification_sender_and_receiver_not_running)
    }

    /**
     * Starts the sender on audio captured from other apps.
     *
     * [resultCode] and [data] are the result of the screen capture prompt, and the order of
     * the steps is dictated by the platform: the user has to accept the prompt before a media
     * projection foreground service may start (Android 14+), and that service has to be
     * running before the projection can be obtained (Android 10+).
     */
    fun startProjectionSender(
        ip: String,
        resultCode: Int,
        data: Intent,
    ) {
        Log.d(LOG_TAG, "Starting Sender With Playback Capture")

        if (isSenderAlive()) return

        senderCapturesPlayback = true
        updateForeground(sending = true, receiving = isReceiverAlive())

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val projection = projectionManager.getMediaProjection(resultCode, data)
        if (projection == null) {
            Log.e(LOG_TAG, "Failed to get media projection")
            onSenderStopped()
            return
        }

        startSender(ip, projection)
    }

    private fun onSenderStopped() {
        senderCapturesPlayback = false
        senderChanged?.invoke(false)
        updateForeground(sending = false, receiving = isReceiverAlive())
    }

    fun startSender(
        ip: String,
        projection: MediaProjection?,
    ) {
        Log.d(LOG_TAG, "Starting Sender")

        if (senderThread?.isAlive == true) return

        senderThread =
            Thread {
                val settings = runBlocking { SettingsRepository.get(this@SenderReceiverService).snapshot() }
                val sourcePort = settings.sourcePort
                val repairPort = settings.repairPort
                val record = createAudioRecord(projection)

                val config =
                    RocSenderConfig.builder()
                        .frameSampleRate(44100)
                        .frameChannels(ChannelSet.STEREO)
                        .frameEncoding(FrameEncoding.PCM_FLOAT)
                        .clockSource(ClockSource.INTERNAL)
                        .build()

                RocContext().use { context ->
                    if (record.state != AudioRecord.STATE_INITIALIZED) {
                        Log.e(LOG_TAG, "Failed to initialize audio record")
                        record.release()
                        onSenderStopped()
                        return@use
                    }

                    record.startRecording()

                    RocSender(context, config).use useSender@{ sender ->
                        try {
                            sender.connect(
                                Slot.DEFAULT,
                                Interface.AUDIO_SOURCE,
                                Endpoint(Protocol.RTP_RS8M_SOURCE, ip, sourcePort),
                            )
                            sender.connect(
                                Slot.DEFAULT,
                                Interface.AUDIO_REPAIR,
                                Endpoint(Protocol.RS8M_REPAIR, ip, repairPort),
                            )
                        } catch (e: Exception) {
                            Log.e(LOG_TAG, "Failed to connect sender", e)
                            senderErrorCallback?.invoke(getString(R.string.invalid_ip_message))
                            return@useSender
                        }

                        senderChanged?.invoke(true)

                        val samples = FloatArray(BUFFER_SIZE)
                        val throttle = StatusThrottle()
                        val startedAt = SystemClock.elapsedRealtime()
                        var windowPeak = 0f
                        var errors = 0

                        try {
                            while (!Thread.currentThread().isInterrupted) {
                                record.read(samples, 0, samples.size, AudioRecord.READ_BLOCKING)
                                sender.write(samples)

                                windowPeak = maxOf(windowPeak, AudioLevel.rms(samples))

                                val now = SystemClock.elapsedRealtime()
                                if (throttle.shouldEmit(now)) {
                                    senderStatusChanged?.invoke(
                                        StreamStatus(
                                            kind = StreamKind.SENDER,
                                            active = true,
                                            host = ip,
                                            sourcePort = sourcePort,
                                            repairPort = repairPort,
                                            elapsedMs = now - startedAt,
                                            level = windowPeak,
                                            errors = errors,
                                        ),
                                    )
                                    windowPeak = 0f
                                }
                            }
                        } catch (e: Exception) {
                            errors++
                            Log.e(LOG_TAG, "Sender stream failed", e)
                        }

                        senderStatusChanged?.invoke(
                            StreamStatus.inactive(
                                StreamKind.SENDER,
                                ip,
                                sourcePort,
                                repairPort,
                                errors = errors,
                            ),
                        )
                    }

                    record.stop()
                    record.release()
                    onSenderStopped()
                }
            }

        senderThread!!.start()
    }

    fun startReceiver() {
        Log.d(LOG_TAG, "Starting Receiver")

        if (receiverThread?.isAlive == true) return

        receiverThread =
            Thread {
                val settings = runBlocking { SettingsRepository.get(this@SenderReceiverService).snapshot() }
                val sourcePort = settings.sourcePort
                val repairPort = settings.repairPort
                val audioTrack = createAudioTrack()
                receiverAudioTrack = audioTrack
                audioTrack.setVolume(PlaybackVolume.toGain(settings.playbackVolume))
                audioTrack.play()

                val config =
                    RocReceiverConfig.builder()
                        .frameSampleRate(44100)
                        .frameChannels(ChannelSet.STEREO)
                        .frameEncoding(FrameEncoding.PCM_FLOAT)
                        .clockSource(ClockSource.INTERNAL)
                        .build()

                RocContext().use { context ->
                    RocReceiver(context, config).use { receiver ->
                        receiver.bind(
                            Slot.DEFAULT,
                            Interface.AUDIO_SOURCE,
                            Endpoint(Protocol.RTP_RS8M_SOURCE, "0.0.0.0", sourcePort),
                        )
                        receiver.bind(
                            Slot.DEFAULT,
                            Interface.AUDIO_REPAIR,
                            Endpoint(Protocol.RS8M_REPAIR, "0.0.0.0", repairPort),
                        )

                        receiverChanged?.invoke(true)

                        val samples = FloatArray(BUFFER_SIZE)
                        val throttle = StatusThrottle()
                        val startedAt = SystemClock.elapsedRealtime()
                        var windowPeak = 0f
                        var errors = 0

                        try {
                            while (!Thread.currentThread().isInterrupted) {
                                receiver.read(samples)
                                audioTrack.write(samples, 0, samples.size, AudioTrack.WRITE_BLOCKING)

                                windowPeak = maxOf(windowPeak, AudioLevel.rms(samples))

                                val now = SystemClock.elapsedRealtime()
                                if (throttle.shouldEmit(now)) {
                                    receiverStatusChanged?.invoke(
                                        StreamStatus(
                                            kind = StreamKind.RECEIVER,
                                            active = true,
                                            sourcePort = sourcePort,
                                            repairPort = repairPort,
                                            elapsedMs = now - startedAt,
                                            level = windowPeak,
                                            underruns = audioTrack.underrunCount,
                                            errors = errors,
                                        ),
                                    )
                                    windowPeak = 0f
                                }
                            }
                        } catch (e: Exception) {
                            errors++
                            Log.e(LOG_TAG, "Receiver stream failed", e)
                        }

                        receiverStatusChanged?.invoke(
                            StreamStatus.inactive(
                                StreamKind.RECEIVER,
                                "",
                                sourcePort,
                                repairPort,
                                underruns = audioTrack.underrunCount,
                                errors = errors,
                            ),
                        )
                    }
                }

                receiverAudioTrack = null
                audioTrack.release()
                receiverChanged?.invoke(false)
                updateForeground(sending = isSenderAlive(), receiving = false)
            }

        receiverThread!!.start()

        updateForeground(sending = isSenderAlive(), receiving = true)
    }

    fun stopSender() {
        Log.d(LOG_TAG, "Stopping Sender")

        senderThread?.interrupt()
    }

    fun stopReceiver() {
        Log.d(LOG_TAG, "Stopping Receiver")

        receiverThread?.interrupt()
    }

    fun setReceiverVolume(percent: Int) {
        val audioTrack = receiverAudioTrack ?: return

        try {
            audioTrack.setVolume(PlaybackVolume.toGain(percent))
        } catch (e: IllegalStateException) {
            Log.w(LOG_TAG, "Failed to set receiver volume", e)
        }
    }

    fun isReceiverAlive(): Boolean {
        Log.d(LOG_TAG, "Checking If Receiver Alive")

        return receiverThread?.isAlive == true
    }

    fun isSenderAlive(): Boolean {
        Log.d(LOG_TAG, "Checking If Sender Alive")

        return senderThread?.isAlive == true
    }

    private fun stopForegroundService() {
        Log.d(LOG_TAG, "Stopping Foreground Service")

        isForegroundRunning = false
        stopForeground(Service.STOP_FOREGROUND_REMOVE)
    }

    private fun createAudioTrack(): AudioTrack {
        Log.d(LOG_TAG, "Creating Audio Track")

        val audioAttributes =
            AudioAttributes.Builder().apply {
                setUsage(AudioAttributes.USAGE_MEDIA)
                setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            }.build()
        val audioFormat =
            AudioFormat.Builder().apply {
                setSampleRate(SAMPLE_RATE)
                setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
            }.build()
        val bufferSize =
            AudioTrack.getMinBufferSize(
                audioFormat.sampleRate,
                audioFormat.channelMask,
                audioFormat.encoding,
            )
        return AudioTrack.Builder().apply {
            setAudioAttributes(audioAttributes)
            setAudioFormat(audioFormat)
            setBufferSizeInBytes(bufferSize)
            setTransferMode(AudioTrack.MODE_STREAM)
            setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
        }.build()
    }

    @SuppressLint("MissingPermission")
    private fun createAudioRecord(projection: MediaProjection?): AudioRecord {
        Log.d(LOG_TAG, "Creating Audio Record")

        val format =
            AudioFormat.Builder().apply {
                setSampleRate(SAMPLE_RATE)
                setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
                setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
            }.build()
        val bufferSize =
            AudioRecord.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_STEREO,
                AudioFormat.ENCODING_PCM_FLOAT,
            )

        return if (projection != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            createPaybackRecord(projection, format, bufferSize)
        } else {
            AudioRecord.Builder().apply {
                setAudioSource(MediaRecorder.AudioSource.DEFAULT)
                setAudioFormat(format)
                setBufferSizeInBytes(bufferSize)
            }.build()
        }
    }

    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun createPaybackRecord(
        projection: MediaProjection,
        format: AudioFormat,
        bufferSize: Int,
    ): AudioRecord {
        Log.d(LOG_TAG, "Creating Playback Record")

        val config =
            AudioPlaybackCaptureConfiguration.Builder(projection).apply {
                addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
                addMatchingUsage(AudioAttributes.USAGE_GAME)
            }.build()

        return AudioRecord.Builder().apply {
            setAudioPlaybackCaptureConfig(config)
            setAudioFormat(format)
            setBufferSizeInBytes(bufferSize)
        }.build()
    }

    fun setSenderStateChangedListeners(senderChanged: (Boolean) -> Unit) {
        Log.d(LOG_TAG, "Setting Sender State Changed Listener")

        this.senderChanged = senderChanged
    }

    fun setReceiverStateChangedListeners(receiverChanged: (Boolean) -> Unit) {
        Log.d(LOG_TAG, "Setting Receiver State Changed Listener")

        this.receiverChanged = receiverChanged
    }

    fun setSenderErrorCallback(callback: (String) -> Unit) {
        Log.d(LOG_TAG, "Setting Sender Error Callback")

        this.senderErrorCallback = callback
    }

    fun setSenderStatusListener(listener: (StreamStatus) -> Unit) {
        Log.d(LOG_TAG, "Setting Sender Status Listener")

        this.senderStatusChanged = listener
    }

    fun setReceiverStatusListener(listener: (StreamStatus) -> Unit) {
        Log.d(LOG_TAG, "Setting Receiver Status Listener")

        this.receiverStatusChanged = listener
    }

    fun removeListeners() {
        Log.d(LOG_TAG, "Removing State Changed Listeners")

        this.receiverChanged = null
        this.senderChanged = null
        this.senderErrorCallback = null
        this.senderStatusChanged = null
        this.receiverStatusChanged = null
    }
}
