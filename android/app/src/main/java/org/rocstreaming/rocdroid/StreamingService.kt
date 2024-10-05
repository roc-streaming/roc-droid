package org.rocstreaming.rocdroid

import AndroidReceiverSettings
import AndroidSenderSettings
import AndroidServiceError
import AndroidServiceEvent
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.os.Binder
import android.os.IBinder
import android.util.Log
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

private const val NOTIFICATION_CHANNEL_ID = "StreamingService"
private const val NOTIFICATION_ID = 1

private const val NOTIFICATION_ACTION_DELETE =
    "org.rocstreaming.rocdroid.NotificationActionDelete"
private const val NOTIFICATION_ACTION_STOP_SENDER =
    "org.rocstreaming.rocdroid.NotificationActionStopSender"
private const val NOTIFICATION_ACTION_STOP_RECEIVER =
    "org.rocstreaming.rocdroid.NotificationActionStopReceiver"

private const val LOG_TAG = "rocdroid.StreamingService"

// Used to report asynchronous events and errors from service.
interface StreamingEventListener {
    fun onEvent(event: AndroidServiceEvent)
    fun onError(error: AndroidServiceError)
}

// This service runs even when the app is closed.
// Related docs:
// https://medium.com/@domen.lanisnik/guide-to-foreground-services-on-android-9d0127dc8f9a
// https://developer.android.com/reference/android/media/projection/MediaProjectionManager
class StreamingService : Service() {
    private var receiverThread: Thread? = null
    private var senderThread: Thread? = null
    private var receiverStarted = false
    private var senderStarted = false
    private var eventListener: StreamingEventListener? = null
    private var autoDetach: Boolean = true
    private var currentProjection: MediaProjection? = null

    private val notificationActionHandler: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.i(LOG_TAG, "Handling notification action: " + intent.action)

            when (intent.action) {
                NOTIFICATION_ACTION_DELETE -> stopAllNoNotification()
                NOTIFICATION_ACTION_STOP_SENDER -> stopSender()
                NOTIFICATION_ACTION_STOP_RECEIVER -> stopReceiver()
            }
        }
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): StreamingService = this@StreamingService
    }

    override fun onBind(intent: Intent): IBinder {
        Log.i(LOG_TAG, "Binding service")

        return binder
    }

    override fun onCreate() {
        Log.i(LOG_TAG, "Creating service")

        super.onCreate()

        initNotifications()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(LOG_TAG, "Starting service")

        startForeground(NOTIFICATION_ID, buildNotification())

        return START_STICKY
    }

    override fun onDestroy() {
        Log.i(LOG_TAG, "Destroying service")

        terminate()
        deinitNotifications()

        super.onDestroy()
    }

    private fun terminate() {
        Log.d(LOG_TAG, "Stopping threads")

        stopSender()
        stopReceiver()

        Log.d(LOG_TAG, "Waiting threads")

        senderThread?.join()
        receiverThread?.join()

        Log.d(LOG_TAG, "Stopping media projection")

        currentProjection?.stop()
        currentProjection = null

        Log.d(LOG_TAG, "Stopping service")

        stopForeground(true)
    }

    @Synchronized
    fun hasProjection(): Boolean {
        return currentProjection != null
    }

    @Synchronized
    fun attachProjection(projection: MediaProjection) {
        Log.i(LOG_TAG, "Attaching media projection")

        currentProjection = projection
    }

    @Synchronized
    fun enableAutoDetach() {
        autoDetach = true
        autoDetachProjection()
    }

    @Synchronized
    fun disableAutoDetach() {
        autoDetach = false
    }

    private fun autoDetachProjection() {
        if (!senderStarted && !receiverStarted && currentProjection != null && autoDetach) {
            Log.i(LOG_TAG, "Detaching media projection")

            currentProjection?.stop()
            currentProjection = null
        }
    }

    @Synchronized
    fun isSenderAlive(): Boolean {
        return senderStarted
    }

    @Synchronized
    fun startSender(settings: AndroidSenderSettings) {
        if (senderStarted) return

        Log.i(LOG_TAG, "Starting sender")

        val projection = currentProjection
        if (projection == null) {
            throw IllegalStateException("Projection not attached")
        }

        val previousThread = senderThread

        senderThread = Thread {
            try {
                if (previousThread != null) {
                    Log.d(LOG_TAG, "Joining previois sender thread")
                    previousThread.join()
                }

                runSenderThread(settings, projection)
            } finally {
                val currentThread = Thread.currentThread()

                synchronized(this@StreamingService) {
                    if (senderThread == currentThread) {
                        stopSender()
                    } else {
                        Log.d(LOG_TAG, "Ignoring dangling sender thread")
                    }
                }
            }
        }

        senderStarted = true
        senderThread!!.start()

        updateNotification()
        reportEvent(AndroidServiceEvent.SENDER_STATE_CHANGED)
    }

    @Synchronized
    fun stopSender() {
        if (!senderStarted) return

        Log.i(LOG_TAG, "Stopping sender")

        senderStarted = false
        senderThread?.interrupt()

        updateNotification()
        autoDetachProjection()

        reportEvent(AndroidServiceEvent.SENDER_STATE_CHANGED)
    }

    @Synchronized
    fun isReceiverAlive(): Boolean {
        return receiverStarted
    }

    @Synchronized
    fun startReceiver(settings: AndroidReceiverSettings) {
        if (receiverStarted) return

        Log.i(LOG_TAG, "Starting receiver")

        val projection = currentProjection
        if (projection == null) {
            throw IllegalStateException("Projection not attached")
        }

        val previousThread = receiverThread

        receiverThread = Thread {
            try {
                if (previousThread != null) {
                    Log.d(LOG_TAG, "Joining previois receiver thread")
                    previousThread.join()
                }

                runReceiverThread(settings, projection)
            } finally {
                val currentThread = Thread.currentThread()

                synchronized(this@StreamingService) {
                    if (receiverThread == currentThread) {
                        stopReceiver()
                    } else {
                        Log.d(LOG_TAG, "Ignoring dangling receiver thread")
                    }
                }
            }
        }

        receiverStarted = true
        receiverThread!!.start()

        updateNotification()
        reportEvent(AndroidServiceEvent.RECEIVER_STATE_CHANGED)
    }

    @Synchronized
    fun stopReceiver() {
        if (!receiverStarted) return

        Log.i(LOG_TAG, "Stopping receiver")

        receiverStarted = false
        receiverThread?.interrupt()

        updateNotification()
        autoDetachProjection()

        reportEvent(AndroidServiceEvent.RECEIVER_STATE_CHANGED)
    }

    @Synchronized
    fun stopAllNoNotification() {
        if (!senderStarted && !receiverStarted) return

        if (senderStarted) {
            Log.i(LOG_TAG, "Stopping sender")

            senderStarted = false
            senderThread?.interrupt()

            reportEvent(AndroidServiceEvent.SENDER_STATE_CHANGED)
        }

        if (receiverStarted) {
            Log.i(LOG_TAG, "Stopping receiver")

            receiverStarted = false
            receiverThread?.interrupt()

            reportEvent(AndroidServiceEvent.RECEIVER_STATE_CHANGED)
        }

        autoDetachProjection()
    }

    @Synchronized
    fun setEventListener(listener: StreamingEventListener) {
        Log.d(LOG_TAG, "Setting event listener")

        eventListener = listener
    }

    @Synchronized
    fun removeEventListener() {
        Log.d(LOG_TAG, "Removing event listener")

        eventListener = null
    }

    @Synchronized
    private fun reportEvent(event: AndroidServiceEvent) {
        Log.d(LOG_TAG, "Reporting event: " + event.toString())

        eventListener?.onEvent(event)
    }

    @Synchronized
    private fun reportError(error: AndroidServiceError) {
        Log.d(LOG_TAG, "Reporting error: " + error.toString())

        eventListener?.onError(error)
    }

    private fun runSenderThread(settings: AndroidSenderSettings, projection: MediaProjection) {
        Log.d(LOG_TAG, "Running sender thread")

        var audioRecord: AudioRecord? = null

        try {
            try {
                if (settings.captureType == AndroidCaptureType.CAPTURE_APPS) {
                    audioRecord = createProjectionAudioRecord(projection)
                } else {
                    audioRecord = createMicrophoneAudioRecord()
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Failed to create audio record: " + e.toString())
                reportError(AndroidServiceError.AUDIO_RECORD_FAILED)
                return
            }

            if (audioRecord.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(LOG_TAG, "Failed to initialize audio record: " + audioRecord.state.toString())
                reportError(AndroidServiceError.AUDIO_RECORD_FAILED)
                return
            }

            val senderConfig = RocSenderConfig.builder()
                .frameSampleRate(44100)
                .frameChannels(ChannelSet.STEREO)
                .frameEncoding(FrameEncoding.PCM_FLOAT)
                .clockSource(ClockSource.EXTERNAL)
                .build()

            RocContext().use { context ->
                RocSender(context, senderConfig).use useSender@{ sender ->
                    try {
                        sender.connect(
                            Slot.DEFAULT,
                            Interface.AUDIO_SOURCE,
                            Endpoint(
                                Protocol.RTP_RS8M_SOURCE,
                                settings.host,
                                settings.sourcePort.toInt()
                            )
                        )
                        sender.connect(
                            Slot.DEFAULT,
                            Interface.AUDIO_REPAIR,
                            Endpoint(
                                Protocol.RS8M_REPAIR,
                                settings.host,
                                settings.repairPort.toInt()
                            )
                        )
                    } catch (e: Exception) {
                        Log.e(LOG_TAG, "Failed to connect sender: " + e.toString())
                        reportError(AndroidServiceError.SENDER_CONNECT_FAILED)
                        return@useSender
                    }

                    audioRecord.startRecording()

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        audioRecord.read(samples, 0, samples.size, AudioRecord.READ_BLOCKING)
                        sender.write(samples)
                    }
                }
            }
        } finally {
            Log.d(LOG_TAG, "Releasing sender resources")

            audioRecord?.stop()
            audioRecord?.release()

            Log.d(LOG_TAG, "Exiting sender thread")
        }
    }

    private fun runReceiverThread(settings: AndroidReceiverSettings, projection: MediaProjection) {
        Log.d(LOG_TAG, "Running receiver thread")

        var audioTrack: AudioTrack? = null

        try {
            try {
                audioTrack = createAudioTrack()
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Failed to create audio track: " + e.toString())
                reportError(AndroidServiceError.AUDIO_TRACK_FAILED)
                return
            }

            if (audioTrack.state != AudioTrack.STATE_INITIALIZED) {
                Log.e(LOG_TAG, "Failed to initialize audio track: " + audioTrack.state.toString())
                reportError(AndroidServiceError.AUDIO_TRACK_FAILED)
                return
            }

            val receiverConfig = RocReceiverConfig.builder()
                .frameSampleRate(44100)
                .frameChannels(ChannelSet.STEREO)
                .frameEncoding(FrameEncoding.PCM_FLOAT)
                .clockSource(ClockSource.EXTERNAL)
                .build()

            RocContext().use { context ->
                RocReceiver(context, receiverConfig).use useReceiver@{ receiver ->
                    try {
                        receiver.bind(
                            Slot.DEFAULT,
                            Interface.AUDIO_SOURCE,
                            Endpoint(
                                Protocol.RTP_RS8M_SOURCE,
                                "0.0.0.0",
                                settings.sourcePort.toInt()
                            )
                        )
                        receiver.bind(
                            Slot.DEFAULT,
                            Interface.AUDIO_REPAIR,
                            Endpoint(
                                Protocol.RS8M_REPAIR,
                                "0.0.0.0",
                                settings.repairPort.toInt()
                            )
                        )
                    } catch (e: Exception) {
                        Log.e(LOG_TAG, "Failed to bind receiver: " + e.toString())
                        reportError(AndroidServiceError.RECEIVER_BIND_FAILED)
                        return@useReceiver
                    }

                    audioTrack.play()

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        receiver.read(samples)
                        audioTrack.write(samples, 0, samples.size, AudioTrack.WRITE_BLOCKING)
                    }
                }
            }
        } finally {
            Log.d(LOG_TAG, "Releasing receiver resources")

            audioTrack?.stop()
            audioTrack?.release()

            Log.d(LOG_TAG, "Exiting receiver thread")
        }
    }

    private fun createAudioTrack(): AudioTrack {
        Log.d(LOG_TAG, "Creating audio track")

        val audioAttributes = AudioAttributes.Builder().apply {
            setUsage(AudioAttributes.USAGE_MEDIA)
            setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        }.build()
        val audioFormat = AudioFormat.Builder().apply {
            setSampleRate(SAMPLE_RATE)
            setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
            setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
        }.build()
        val bufferSize = AudioTrack.getMinBufferSize(
            audioFormat.sampleRate,
            audioFormat.channelMask,
            audioFormat.encoding
        )
        return AudioTrack.Builder().apply {
            setAudioAttributes(audioAttributes)
            setAudioFormat(audioFormat)
            setBufferSizeInBytes(bufferSize)
            setTransferMode(AudioTrack.MODE_STREAM)
            setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
        }.build()
    }

    private fun createMicrophoneAudioRecord(): AudioRecord {
        Log.d(LOG_TAG, "Creating microphone audio record")

        val format = AudioFormat.Builder().apply {
            setSampleRate(SAMPLE_RATE)
            setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
            setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
        }.build()
        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_STEREO,
            AudioFormat.ENCODING_PCM_FLOAT
        )
        return AudioRecord.Builder().apply {
            setAudioSource(MediaRecorder.AudioSource.DEFAULT)
            setAudioFormat(format)
            setBufferSizeInBytes(bufferSize)
        }.build()
    }

    private fun createProjectionAudioRecord(projection: MediaProjection): AudioRecord {
        Log.d(LOG_TAG, "Creating projection audio record")

        val format = AudioFormat.Builder().apply {
            setSampleRate(SAMPLE_RATE)
            setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
            setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
        }.build()
        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_STEREO,
            AudioFormat.ENCODING_PCM_FLOAT
        )
        val config = AudioPlaybackCaptureConfiguration.Builder(projection).apply {
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

    private fun initNotifications() {
        Log.d(LOG_TAG, "Initializing notifications")

        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW
        )

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        notificationManager.createNotificationChannel(channel)

        registerReceiver(
            notificationActionHandler,
            IntentFilter().apply {
                addAction(NOTIFICATION_ACTION_DELETE)
                addAction(NOTIFICATION_ACTION_STOP_SENDER)
                addAction(NOTIFICATION_ACTION_STOP_RECEIVER)
            },
            RECEIVER_EXPORTED
        )
    }

    private fun deinitNotifications() {
        Log.d(LOG_TAG, "Deinitializing notifications")

        unregisterReceiver(notificationActionHandler)
    }

    private fun buildNotification(): Notification {
        Log.d(LOG_TAG, "Building notification: actions=" + getNotificationDesc())

        // invoked when notification is tapped
        // we want to open main activity
        val contentIntent = Intent(this, MainActivity::class.java)
        val pendingContentIntent = PendingIntent.getActivity(
            this,
            0,
            contentIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        // invoked when notification is dismissed (swiped away)
        // we want to stop sender & receiver
        val deleteIntent = Intent(NOTIFICATION_ACTION_DELETE)
        val pendingDeleteIntent = PendingIntent.getBroadcast(
            this,
            0,
            deleteIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        // invoked when "stop sender" notification button is pressed
        val stopSenderIntent = Intent(NOTIFICATION_ACTION_STOP_SENDER)
        val pendingStopSenderIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopSenderIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        val stopSenderAction = Notification.Action.Builder(
            Icon.createWithResource(this@StreamingService, R.drawable.ic_stop),
            getString(R.string.notification_stop_sender_action),
            pendingStopSenderIntent
        ).build()

        // invoked when "stop receiver" notification button is pressed
        val stopReceiverIntent = Intent(NOTIFICATION_ACTION_STOP_RECEIVER)
        val pendingStopReceiverIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopReceiverIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        val stopReceiverAction = Notification.Action.Builder(
            Icon.createWithResource(this@StreamingService, R.drawable.ic_stop),
            getString(R.string.notification_stop_receiver_action),
            pendingStopReceiverIntent
        ).build()

        return Notification.Builder(this, NOTIFICATION_CHANNEL_ID).apply {
            // appearance
            setSmallIcon(R.drawable.ic_notification)
            setContentTitle(getString(R.string.notification_title))
            setContentText(getNotificationText())
            // when notification is tapped
            setContentIntent(pendingContentIntent)
            // when notification is swiped away
            setDeleteIntent(pendingDeleteIntent)
            // don't allow to dimiss notification on lock screen
            setOngoing(true)
            // show on lock screen
            setVisibility(Notification.VISIBILITY_PUBLIC)
            // notification buttons
            if (senderStarted) {
                addAction(stopSenderAction)
            }
            if (receiverStarted) {
                addAction(stopReceiverAction)
            }
        }.build()
    }

    private fun updateNotification() {
        Log.d(LOG_TAG, "Updating notification: actions=" + getNotificationDesc())

        val notification = buildNotification()
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun getNotificationText(): String {
        return when {
            senderStarted && receiverStarted ->
                getString(R.string.notification_sender_and_receiver_running)
            senderStarted -> getString(R.string.notification_sender_running)
            receiverStarted -> getString(R.string.notification_receiver_running)
            else -> getString(R.string.notification_sender_and_receiver_not_running)
        }
    }

    private fun getNotificationDesc(): String {
        return when {
            senderStarted && receiverStarted -> "[sender, receiver]"
            senderStarted -> "[sender]"
            receiverStarted -> "[receiver]"
            else -> "[]"
        }
    }
}
