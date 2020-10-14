package org.rocstreaming.rocdroid

import android.Manifest
import android.content.pm.PackageManager
import android.media.*
import android.os.Bundle
import android.text.Html
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import org.rocstreaming.roctoolkit.*
import java.net.NetworkInterface

private const val SAMPLE_RATE = 44100
private const val BUFFER_SIZE = 100

private const val RTP_PORT_SOURCE = 11001
private const val RTP_PORT_REPAIR = 11002

class MainActivity : AppCompatActivity() {
    private var receiverThread: Thread? = null
    private var senderThread: Thread? = null

    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var receiverIpEdit: EditText

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        volumeControlStream = AudioManager.STREAM_MUSIC

        findViewById<TextView>(R.id.receiverExplanation).text =
            Html.fromHtml(getText(R.string.receiver_expl).toString().format(getIpAddresses()), 0)

        receiverIpEdit = findViewById(R.id.receiverIp)

        requestPermissionLauncher =
            registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
                if (isGranted) {
                    AlertDialog.Builder(this@MainActivity).apply {
                        setTitle(R.string.allow_mic_title)
                        setMessage(getString(R.string.allow_mic_ok_message))
                        setCancelable(false)
                        setPositiveButton(R.string.ok) { _, _ -> startStopSender(null) }
                    }.show()
                }
            }
    }

    override fun onResume() {
        super.onResume()
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    /**
     * Start roc receiver in separated thread and play samples via audioTrack
     */
    fun startStopReceiver(@Suppress("UNUSED_PARAMETER") view: View) {
        if (receiverThread?.isAlive == true) {
            receiverThread?.interrupt()
        } else {
            startReceiver()
        }
        setReceiverButtonState()
    }

    private fun startReceiver() {
        if (receiverThread?.isAlive == true) return

        receiverThread = Thread(Runnable {
            val audioTrack = createAudioTrack()
            audioTrack.play()

            val config = ReceiverConfig.Builder(
                SAMPLE_RATE,
                ChannelSet.STEREO,
                FrameEncoding.PCM_FLOAT
            ).build()

            Context().use { context ->
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

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        receiver.read(samples)
                        audioTrack.write(samples, 0, samples.size, AudioTrack.WRITE_BLOCKING)
                    }
                }
            }

            audioTrack.release()
        })

        receiverThread!!.start()
    }

    fun startStopSender(@Suppress("UNUSED_PARAMETER") view: View?) {
        if (senderThread?.isAlive == true) {
            senderThread?.interrupt()
        } else {
            startSender()
        }
        setSenderButtonState()
    }

    fun startSender() {
        if (senderThread?.isAlive == true) return

        if (!askForRecordAudioPermission()) return

        val ip = receiverIpEdit.text.toString()

        senderThread = Thread(Runnable {
            val record = createAudioRecord()

            val config = SenderConfig.Builder(
                SAMPLE_RATE,
                ChannelSet.STEREO,
                FrameEncoding.PCM_FLOAT
            ).build()

            Context().use { context ->
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
                        AlertDialog.Builder(this@MainActivity).apply {
                            setTitle(getString(R.string.invalid_ip_title))
                            setMessage(getString(R.string.invalid_ip_message))
                            setCancelable(false)
                            setPositiveButton(R.string.ok) { _, _ -> }
                        }.show()
                        return@use
                    }

                    val samples = FloatArray(BUFFER_SIZE)
                    while (!Thread.currentThread().isInterrupted) {
                        record.read(samples, 0, samples.size, AudioRecord.READ_BLOCKING)
                        sender.write(samples)
                    }
                }

                record.stop()
                record.release()
            }
        })

        senderThread!!.start()
    }

    private fun askForRecordAudioPermission(): Boolean = when {
        ContextCompat.checkSelfPermission(
            this@MainActivity,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED -> {
            // Permission already granted.
            true
        }
        shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO) -> {
            AlertDialog.Builder(this@MainActivity).apply {
                setTitle(getString(R.string.allow_mic_title))
                setMessage(getString(R.string.allow_mic_message))
                setCancelable(false)
                setPositiveButton(R.string.ok) { _, _ -> }
            }.show()
            false
        }
        else -> {
            requestPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
            false
        }
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

    private fun getIpAddresses(): String {
        try {
            return NetworkInterface.getNetworkInterfaces().toList()
                .flatMap { it.inetAddresses.toList() }
                .filter { !it.isLoopbackAddress && !it.hostAddress.contains(':') }
                .joinToString("\n") { it.hostAddress }
        } catch (ignored: Exception) {
        }
        return ""
    }

    private fun setButtonState(
        thread: Thread?,
        button: Int,
        startString: Int,
        stopString: Int
    ): Boolean {
        val alive = thread?.isAlive == true && !thread.isInterrupted
        findViewById<Button>(button).text = getText(if (alive) stopString else startString)
        return alive
    }

    private fun setReceiverButtonState() {
        setButtonState(
            receiverThread,
            R.id.startReceiver,
            R.string.start_receiver,
            R.string.stop_receiver
        )
    }

    private fun setSenderButtonState() {
        val alive = setButtonState(
            senderThread,
            R.id.startSender,
            R.string.start_sender,
            R.string.stop_sender
        )
        findViewById<EditText>(R.id.receiverIp).isEnabled = !alive
    }
}
