package org.rocstreaming.rocdroid

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Icon
import android.media.*
import android.os.Binder
import android.os.IBinder
import androidx.appcompat.app.AlertDialog
import org.rocstreaming.roctoolkit.*

private const val SAMPLE_RATE = 44100
private const val BUFFER_SIZE = 100

private const val RTP_PORT_SOURCE = 11001
private const val RTP_PORT_REPAIR = 11002

private const val CHANNEL_ID = "SenderReceiverService"
private const val NOTIFICATION_ID = 1
private const val BROADCAST_STOP_ACTION = "org.rocstreaming.rocdroid.NotificationStopAction"

class SenderReceiverService : Service() {

    private var receiverThread: Thread? = null
    private var senderThread: Thread? = null
    private var receiverChanged: ((Boolean) -> Unit)? = null
    private var senderChanged: ((Boolean) -> Unit)? = null
    private var isForegroundRunning = false

    private val notificationStopActionReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            stopForegroundService()
            stopSender()
            stopReceiver()
        }
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): SenderReceiverService = this@SenderReceiverService
    }

    override fun onBind(intent: Intent): IBinder? {
        return binder
    }

    override fun onCreate() {
        createNotificationChannel()
        registerReceiver(notificationStopActionReceiver, IntentFilter(BROADCAST_STOP_ACTION))
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(notificationStopActionReceiver)
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW
        )
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(channel)
    }

    private fun buildNotification(sending: Boolean, receiving: Boolean): Notification {
        val mainActivityIntent = Intent(this, MainActivity::class.java)
        val pendingMainActivityIntent = PendingIntent.getActivity(
            this,
            0,
            mainActivityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopIntent = Intent(BROADCAST_STOP_ACTION)
        val pendingStopIntent = PendingIntent.getBroadcast(
            this@SenderReceiverService,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopAction = Notification.Action.Builder(
            Icon.createWithResource(this@SenderReceiverService, R.drawable.ic_stop),
            getString(R.string.notification_stop_action),
            pendingStopIntent
        ).build()
        return Notification.Builder(this, CHANNEL_ID).apply {
            setContentTitle(getString(R.string.notification_title))
            setContentText(getContentText(sending, receiving))
            setSmallIcon(R.drawable.ic_launcher_foreground)
            setVisibility(Notification.VISIBILITY_PUBLIC)
            setContentIntent(pendingMainActivityIntent)
            addAction(stopAction)
        }.build()
    }

    private fun updateNotification(sending: Boolean, receiving: Boolean) {
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
        if (sending && receiving) {
            return getString(R.string.notification_sender_and_receiver_running)
        }
        if (receiving) {
            return getString(R.string.notification_receiver_running)
        }
        if (sending) {
            return getString(R.string.notification_sender_running)
        }
        return getString(R.string.notification_sender_and_receiver_not_running)//this shouldn't happen
    }

    fun startSender(ip: String) {
        if (senderThread?.isAlive == true) return

        senderThread = Thread(Runnable {
            val record = createAudioRecord()

            val config = SenderConfig.Builder(
                SAMPLE_RATE,
                ChannelSet.STEREO,
                FrameEncoding.PCM_FLOAT
            ).build()

            org.rocstreaming.roctoolkit.Context().use { context ->
                if (record.state != AudioRecord.STATE_INITIALIZED) return@use

                record.startRecording()

                Sender(context, config).use { sender ->
                    sender.bind(Address(Family.AUTO, "0.0.0.0", 0))

                    try {
                        sender.connect(
                            PortType.AUDIO_SOURCE, Protocol.RTP_RS8M_SOURCE,
                            Address(Family.AUTO, ip, RTP_PORT_SOURCE)
                        )
                        sender.connect(
                            PortType.AUDIO_REPAIR, Protocol.RS8M_REPAIR,
                            Address(Family.AUTO, ip, RTP_PORT_REPAIR)
                        )
                    } catch (e: Exception) {
                        AlertDialog.Builder(this@SenderReceiverService).apply {
                            setTitle(getString(R.string.invalid_ip_title))
                            setMessage(getString(R.string.invalid_ip_message))
                            setCancelable(false)
                            setPositiveButton(R.string.ok) { _, _ -> }
                        }.show()
                        return@use
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
        })

        senderThread!!.start()

        if (isForegroundRunning) {
            updateNotification(true, isReceiverAlive())
        } else {
            startForegroundService(true, isReceiverAlive())
        }
    }

    fun startReceiver() {
        if (receiverThread?.isAlive == true) return

        receiverThread = Thread(Runnable {
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
                        Address(Family.AUTO, "0.0.0.0", 10001)
                    )
                    receiver.bind(
                        PortType.AUDIO_REPAIR,
                        Protocol.RS8M_REPAIR,
                        Address(Family.AUTO, "0.0.0.0", 10002)
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
        })

        receiverThread!!.start()

        if (isForegroundRunning) {
            updateNotification(isSenderAlive(), true)
        } else {
            startForegroundService(isSenderAlive(), true)
        }
    }

    fun stopSender() {
        senderThread?.interrupt()
    }

    fun stopReceiver() {
        receiverThread?.interrupt()
    }

    fun isReceiverAlive(): Boolean {
        return receiverThread?.isAlive == true
    }

    fun isSenderAlive(): Boolean {
        return senderThread?.isAlive == true
    }

    private fun startForegroundService(sending: Boolean, receiving: Boolean) {
        isForegroundRunning = true
        startForeground(NOTIFICATION_ID, buildNotification(sending, receiving))
    }

    private fun stopForegroundService() {
        isForegroundRunning = false
        stopForeground(true)
    }

    private fun createAudioTrack(): AudioTrack {
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
            setSessionId(AudioManager.AUDIO_SESSION_ID_GENERATE)
            setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
        }.build()
    }

    private fun createAudioRecord(): AudioRecord {
        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_STEREO,
            AudioFormat.ENCODING_PCM_FLOAT
        )
        return AudioRecord.Builder().apply {
            setAudioSource(MediaRecorder.AudioSource.DEFAULT)
            setAudioFormat(AudioFormat.Builder().apply {
                setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
                setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                setSampleRate(SAMPLE_RATE)
            }.build())
            setBufferSizeInBytes(bufferSize)
        }.build()
    }

    fun setStateChangedListeners(
        senderChanged: (Boolean) -> Unit,
        receiverChanged: (Boolean) -> Unit
    ) {
        this.receiverChanged = receiverChanged
        this.senderChanged = senderChanged
    }

    fun removeListeners() {
        this.receiverChanged = null
        this.senderChanged = null
    }
}
