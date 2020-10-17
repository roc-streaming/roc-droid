package org.rocstreaming.rocdroid

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Bundle
import android.os.IBinder
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
import java.net.NetworkInterface

class MainActivity : AppCompatActivity() {

    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var receiverIpEdit: EditText
    private lateinit var senderReceiverService: SenderReceiverService

    private val senderReceiverServiceConnection = object : ServiceConnection {

        override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
            senderReceiverService = (binder as SenderReceiverService.LocalBinder).getService()
            senderReceiverService.setStateChangedListeners(
                senderChanged = { state: Boolean -> runOnUiThread { setSenderButtonState(state) } },
                receiverChanged = { state: Boolean -> runOnUiThread { setReceiverButtonState(state) } })
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            senderReceiverService.removeListeners()
        }
    }

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

        val serviceIntent = Intent(this, SenderReceiverService::class.java)
        bindService(serviceIntent, senderReceiverServiceConnection, BIND_AUTO_CREATE)
    }

    override fun onResume() {
        super.onResume()
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun onDestroy() {
        super.onDestroy()
        unbindService(senderReceiverServiceConnection)
    }

    /**
     * Start roc receiver in separated thread and play samples via audioTrack
     */
    fun startStopReceiver(@Suppress("UNUSED_PARAMETER") view: View) {
        if (senderReceiverService.isReceiverAlive()) {
            senderReceiverService.stopReceiver()
        } else {
            senderReceiverService.startReceiver()
        }
    }

    fun startStopSender(@Suppress("UNUSED_PARAMETER") view: View?) {
        if (senderReceiverService.isSenderAlive()) {
            senderReceiverService.stopSender()
        } else {
            if (!askForRecordAudioPermission()) return

            val ip = receiverIpEdit.text.toString()
            senderReceiverService.startSender(ip)
        }
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
        isRunning: Boolean,
        button: Int,
        startString: Int,
        stopString: Int
    ): Boolean {
        findViewById<Button>(button).text = getText(if (isRunning) stopString else startString)
        return isRunning
    }

    private fun setReceiverButtonState(isRunning: Boolean) {
        setButtonState(
            isRunning,
            R.id.startReceiver,
            R.string.start_receiver,
            R.string.stop_receiver
        )
    }

    private fun setSenderButtonState(isRunning: Boolean) {
        val alive = setButtonState(
            isRunning,
            R.id.startSender,
            R.string.start_sender,
            R.string.stop_sender
        )
        findViewById<EditText>(R.id.receiverIp).isEnabled = !alive
    }
}
