package org.rocstreaming.rocdroid

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
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import org.rocstreaming.roctoolkit.Address
import org.rocstreaming.roctoolkit.ChannelSet
import org.rocstreaming.roctoolkit.Family
import org.rocstreaming.roctoolkit.FrameEncoding
import org.rocstreaming.roctoolkit.PortType
import org.rocstreaming.roctoolkit.Protocol
import org.rocstreaming.roctoolkit.Receiver
import org.rocstreaming.roctoolkit.ReceiverConfig
import org.rocstreaming.roctoolkit.Sender
import org.rocstreaming.roctoolkit.SenderConfig

private const val SAMPLE_RATE = 44100
private const val BUFFER_SIZE = 100

private const val DEFAULT_RTP_PORT_SOURCE = 10001
private const val DEFAULT_RTP_PORT_REPAIR = 10002

private const val CHANNEL_ID = "SenderReceiverService"
private const val NOTIFICATION_ID = 1

private const val BROADCAST_STOP_SENDER_ACTION =
    "org.rocstreaming.rocdroid.NotificationSenderStopAction"
private const val BROADCAST_STOP_RECEIVER_ACTION =
    "org.rocstreaming.rocdroid.NotificationReceiverStopAction"

private const val LOG_TAG = "[rocdroid.SenderReceiverService]"

class SenderReceiverService : Service() {
    private var receiverThread: Thread? = null
    private var senderThread: Thread? = null
    private var receiverChanged: ((Boolean) -> Unit)? = null
    private var senderChanged: ((Boolean) -> Unit)? = null
    private var isForegroundRunning = false

    private val notificationStopActionReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
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
        registerReceiver(
            notificationStopActionReceiver,
            IntentFilter().apply {
                addAction(BROADCAST_STOP_SENDER_ACTION)
                addAction(BROADCAST_STOP_RECEIVER_ACTION)
            }
        )
    }

    override fun onDestroy() {
        Log.d(LOG_TAG, "Destroying Sender/Receiver Service")

        super.onDestroy()
        unregisterReceiver(notificationStopActionReceiver)
    }

    private fun createNotificationChannel() {
        Log.d(LOG_TAG, "Creating Notification Channel")

        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW
        )
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(channel)
    }

    private fun buildNotification(sending: Boolean, receiving: Boolean): Notification {
        Log.d(
            LOG_TAG,
            String.format(
                "Building Notification for %s %s",
                if (sending) "Sender" else "",
                if (receiving) "Receiver" else ""
            )
        )

        val mainActivityIntent = Intent(this, MainActivity::class.java)
        val pendingMainActivityIntent = PendingIntent.getActivity(
            this,
            0,
            mainActivityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopSenderIntent = Intent(BROADCAST_STOP_SENDER_ACTION)
        val pendingStopSenderIntent = PendingIntent.getBroadcast(
            this@SenderReceiverService,
            0,
            stopSenderIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopReceiverIntent = Intent(BROADCAST_STOP_RECEIVER_ACTION)
        val pendingStopReceiverIntent = PendingIntent.getBroadcast(
            this@SenderReceiverService,
            0,
            stopReceiverIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopSenderAction = Notification.Action.Builder(
            Icon.createWithResource(this@SenderReceiverService, R.drawable.ic_stop),
            getString(R.string.notification_stop_sender_action),
            pendingStopSenderIntent
        ).build()
        val stopReceiverAction = Notification.Action.Builder(
            Icon.createWithResource(this@SenderReceiverService, R.drawable.ic_stop),
            getString(R.string.notification_stop_receiver_action),
            pendingStopReceiverIntent
        ).build()
        return Notification.Builder(this, CHANNEL_ID).apply {
            setContentTitle(getString(R.string.notification_title))
            setContentText(getContentText(sending, receiving))
            setSmallIcon(R.drawable.ic_launcher_foreground)
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

    private fun updateNotification(sending: Boolean, receiving: Boolean) {
        Log.d(
            LOG_TAG,
            String.format(
                "Updating Notification for %s %s",
                if (sending) "Sender" else "",
                if (receiving) "Receiver" else ""
            )
        )

        if (!isForegroundRunning) {
            return
        }

        if (receiving || sending) {
            val notification = buildNotification(sending, receiving)
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(NOTIFICATION_ID, notification)
        } else {
            stopForegroundService()
        }
    }

    private fun getContentText(sending: Boolean, receiving: Boolean): String {
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
        return getString(R.string.notification_sender_and_receiver_not_running) // this shouldn't happen
    }

    fun preStartSender() {
        Log.d(LOG_TAG, "Prestart Sender")

        if (isForegroundRunning) {
            updateNotification(true, isReceiverAlive())
        } else {
            startForegroundService(true, isReceiverAlive())
        }
    }

    fun startSender(ip: String, projection: MediaProjection?) {
        Log.d(LOG_TAG, "Starting Sender")

        if (senderThread?.isAlive == true) return

        senderThread = Thread {
            val record = createAudioRecord(projection)

            val config = SenderConfig.Builder(
                SAMPLE_RATE,
                ChannelSet.STEREO,
                FrameEncoding.PCM_FLOAT
            ).build()

            org.rocstreaming.roctoolkit.Context().use { context ->
                if (record.state != AudioRecord.STATE_INITIALIZED) return@use

                record.startRecording()

                Sender(context, config).use useSender@{ sender ->
                    sender.bind(Address(Family.AUTO, "0.0.0.0", 0))

                    try {
                        sender.connect(
                            PortType.AUDIO_SOURCE,
                            Protocol.RTP_RS8M_SOURCE,
                            Address(Family.AUTO, ip, DEFAULT_RTP_PORT_SOURCE)
                        )
                        sender.connect(
                            PortType.AUDIO_REPAIR,
                            Protocol.RS8M_REPAIR,
                            Address(Family.AUTO, ip, DEFAULT_RTP_PORT_REPAIR)
                        )
                    } catch (e: Exception) {
                        AlertDialog.Builder(this@SenderReceiverService).apply {
                            setTitle(getString(R.string.invalid_ip_title))
                            setMessage(getString(R.string.invalid_ip_message))
                            setCancelable(false)
                            setPositiveButton(R.string.ok) { _, _ -> }
                        }.show()
                        return@useSender
                    }

                    senderChanged?.invoke(true)

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        record.read(samples, 0, samples.size, AudioRecord.READ_BLOCKING)
                        sender.write(samples)
                    }
                }

                record.stop()
                record.release()
                senderChanged?.invoke(false)
                updateNotification(false, isReceiverAlive())
            }
        }

        senderThread!!.start()
    }

    fun startReceiver() {
        Log.d(LOG_TAG, "Starting Receiver")

        if (receiverThread?.isAlive == true) return

        receiverThread = Thread {
            val audioTrack = createAudioTrack()
            audioTrack.play()

            val config = ReceiverConfig.Builder(
                SAMPLE_RATE,
                ChannelSet.STEREO,
                FrameEncoding.PCM_FLOAT
            ).build()

            org.rocstreaming.roctoolkit.Context().use { context ->
                Receiver(context, config).use { receiver ->
                    receiver.bind(
                        PortType.AUDIO_SOURCE,
                        Protocol.RTP_RS8M_SOURCE,
                        Address(Family.AUTO, "0.0.0.0", DEFAULT_RTP_PORT_SOURCE)
                    )
                    receiver.bind(
                        PortType.AUDIO_REPAIR,
                        Protocol.RS8M_REPAIR,
                        Address(Family.AUTO, "0.0.0.0", DEFAULT_RTP_PORT_REPAIR)
                    )

                    receiverChanged?.invoke(true)

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        receiver.read(samples)
                        audioTrack.write(samples, 0, samples.size, AudioTrack.WRITE_BLOCKING)
                    }
                }
            }

            audioTrack.release()
            receiverChanged?.invoke(false)
            updateNotification(isSenderAlive(), false)
        }

        receiverThread!!.start()

        if (isForegroundRunning) {
            updateNotification(isSenderAlive(), true)
        } else {
            startForegroundService(isSenderAlive(), true)
        }
    }

    fun stopSender() {
        Log.d(LOG_TAG, "Stopping Sender")

        senderThread?.interrupt()
    }

    fun stopReceiver() {
        Log.d(LOG_TAG, "Stopping Receiver")

        receiverThread?.interrupt()
    }

    fun isReceiverAlive(): Boolean {
        Log.d(LOG_TAG, "Checking If Receiver Alive")

        return receiverThread?.isAlive == true
    }

    fun isSenderAlive(): Boolean {
        Log.d(LOG_TAG, "Checking If Sender Alive")

        return senderThread?.isAlive == true
    }

    private fun startForegroundService(sending: Boolean, receiving: Boolean) {
        Log.d(
            LOG_TAG,
            String.format(
                "Starting Foreground Service for %s %s",
                if (sending) "Sender" else "",
                if (receiving) "Receiver" else ""
            )
        )

        isForegroundRunning = true
        startForeground(NOTIFICATION_ID, buildNotification(sending, receiving))
    }

    private fun stopForegroundService() {
        Log.d(LOG_TAG, "Stopping Foreground Service")

        isForegroundRunning = false
        stopForeground(true)
    }

    private fun createAudioTrack(): AudioTrack {
        Log.d(LOG_TAG, "Creating Audio Track")

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

    private fun createAudioRecord(projection: MediaProjection?): AudioRecord {
        Log.d(LOG_TAG, "Creating Audio Record")

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

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun createPaybackRecord(
        projection: MediaProjection,
        format: AudioFormat,
        bufferSize: Int
    ): AudioRecord {
        Log.d(LOG_TAG, "Creating Playback Record")

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

    fun setSenderStateChangedListeners(
        senderChanged: (Boolean) -> Unit
    ) {
        Log.d(LOG_TAG, "Setting Sender State Changed Listener")

        this.senderChanged = senderChanged
    }

    fun setReceiverStateChangedListeners(
        receiverChanged: (Boolean) -> Unit
    ) {
        Log.d(LOG_TAG, "Setting Receiver State Changed Listener")

        this.receiverChanged = receiverChanged
    }

    fun removeListeners() {
        Log.d(LOG_TAG, "Removing State Changed Listeners")

        this.receiverChanged = null
        this.senderChanged = null
    }
}
