package com.github.rocproject.rocdroid

import android.media.AudioAttributes
import android.media.AudioAttributes.USAGE_MEDIA
import android.media.AudioFormat
import android.media.AudioFormat.CHANNEL_OUT_STEREO
import android.media.AudioFormat.ENCODING_PCM_FLOAT
import android.media.AudioManager.AUDIO_SESSION_ID_GENERATE
import android.media.AudioTrack
import android.media.AudioTrack.MODE_STREAM
import android.media.AudioTrack.PERFORMANCE_MODE_LOW_LATENCY
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.github.rocproject.roc.*
import java.net.NetworkInterface

const val SAMPLE_RATE = 44100
const val BUFFER_SIZE = 100

class MainActivity : AppCompatActivity() {

    private var thread: Thread? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val ipTextView: TextView = findViewById(R.id.ipTextView)
        ipTextView.text = getIpAddresses()
    }

    /**
     * Start roc receiver in separated thread and play samples via audioTrack
     */
    fun startReceiver(@Suppress("UNUSED_PARAMETER") view: View) {
        if (thread?.isAlive == true) {
            return
        }

        thread = Thread(Runnable {
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

        thread!!.start()
    }

    /**
     * Stop roc receiver and audioTrack
     */
    fun stopReceiver(@Suppress("UNUSED_PARAMETER") view: View) {
        thread?.interrupt()
    }

    private fun createAudioTrack(): AudioTrack {
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(USAGE_MEDIA)
            .setFlags(PERFORMANCE_MODE_LOW_LATENCY)
            .build()
        val audioFormat = AudioFormat.Builder()
            .setSampleRate(SAMPLE_RATE)
            .setEncoding(ENCODING_PCM_FLOAT)
            .setChannelMask(CHANNEL_OUT_STEREO)
            .build()

        val bufferSize = AudioTrack.getMinBufferSize(
            audioFormat.sampleRate,
            audioFormat.encoding,
            audioFormat.channelMask
        )

        return AudioTrack(
            audioAttributes,
            audioFormat,
            bufferSize,
            MODE_STREAM,
            AUDIO_SESSION_ID_GENERATE
        )
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
}
