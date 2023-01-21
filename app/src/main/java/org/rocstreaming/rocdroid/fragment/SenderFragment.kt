package org.rocstreaming.rocdroid.fragment

import android.Manifest
import android.content.Context.MEDIA_PROJECTION_SERVICE
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.SenderReceiverService
import org.rocstreaming.rocdroid.component.CopyBlock


class SenderFragment : Fragment() {

    private lateinit var selectedAudioSource: String
    private lateinit var audioSources: Array<String>
    private var selectedAudioSourceIndex: Int = 0
    private lateinit var senderService: SenderReceiverService
    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var projectionLauncher: ActivityResultLauncher<Intent>
    private lateinit var projectionManager: MediaProjectionManager
    private lateinit var receiverIpEdit: EditText
    private lateinit var usePlaybackCapture: TextView
    private lateinit var projection: MediaProjection

    private lateinit var prefs: SharedPreferences

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.sender_fragment, container, false)

        usePlaybackCapture = view.findViewById(R.id.audio_source)
        receiverIpEdit = view.findViewById(R.id.receiverIp)

        prefs = activity?.getSharedPreferences("settings", android.content.Context.MODE_PRIVATE)!!

        audioSources = arrayOf(
            getText(R.string.sender_audio_source_current_apps).toString(),
            getText(R.string.sender_audio_source_microphone).toString()
        )

        view.findViewById<TextView>(R.id.audio_source)?.text =
            audioSources[selectedAudioSourceIndex]
        view.findViewById<CopyBlock>(R.id.sourcePortValue)?.setText("10001")
        view.findViewById<CopyBlock>(R.id.repairPortValue)?.setText("10002")

        view.findViewById<TextView>(R.id.portForSource).text =
            getText(R.string.receiver_sender_port_for_source).toString().format(2)
        view.findViewById<TextView>(R.id.portForRepair).text =
            getText(R.string.receiver_sender_port_for_repair).toString().format(3)

        val showAudioSourceDialog: ConstraintLayout =
            view.findViewById(R.id.audio_source_dialog_button)

        showAudioSourceDialog.setOnClickListener {
            showRadioConfirmationDialog()
        }

        view.findViewById<Button>(R.id.startSenderButton).setOnClickListener {
            startStopSender(null)
        }

        projectionLauncher = registerForActivityResult(StartActivityForResult()) { result ->
            if (result.data != null) {
                projection = projectionManager.getMediaProjection(result.resultCode, result.data!!)
                val ip = receiverIpEdit.text.toString()
                senderService.startSender(ip, projection)
            }
        }

        requestPermissionLauncher =
            registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
                if (isGranted) {
                    AlertDialog.Builder(requireActivity()).apply {
                        setTitle(R.string.allow_mic_title)
                        setMessage(getString(R.string.allow_mic_ok_message))
                        setCancelable(false)
                        setPositiveButton(R.string.ok) { _, _ -> startStopSender(null) }
                    }.show()
                }
            }

        return view
    }

    fun onServiceConnected(
        service: SenderReceiverService,
        showActiveIcon: (Int) -> Unit,
        hideActiveIcon: (Int) -> Unit
    ) {
        senderService = service

        senderService.setSenderStateChangedListeners(
            senderChanged = { state: Boolean ->
                activity?.runOnUiThread {
                    activity?.findViewById<Button>(R.id.startSenderButton)?.text =
                        getText(if (state) R.string.stop_sender else R.string.start_sender)
                    if (state) showActiveIcon(1) else hideActiveIcon(1)
                }
            }
        )
    }

    private fun showRadioConfirmationDialog() {
        selectedAudioSource = audioSources[selectedAudioSourceIndex]
        MaterialAlertDialogBuilder(requireActivity())
            .setTitle(getText(R.string.dialog_choose_audio_source).toString())
            .setSingleChoiceItems(audioSources, selectedAudioSourceIndex) { dialog_, which ->
                selectedAudioSourceIndex = which
                selectedAudioSource = audioSources[which]
            }
            .setPositiveButton("Ok") { dialog, which ->
                view?.findViewById<TextView>(R.id.audio_source)?.text = selectedAudioSource
            }
            .setNegativeButton("Cancel") { dialog, which ->
                dialog.dismiss()
            }
            .show()
    }

    fun isUsePlayback(): Boolean {
        return usePlaybackCapture.text == audioSources[0]
    }

    fun startStopSender(@Suppress("UNUSED_PARAMETER") view: View?) {
        if (senderService.isSenderAlive()) {
            senderService.stopSender()
        } else {
            val editor = prefs.edit()
            editor.putBoolean("playback_capture", isUsePlayback())
            editor.putString("receiver_ip", receiverIpEdit.text.toString())
            editor.apply()

            if (!askForRecordAudioPermission()) return

            if (isUsePlayback()) {
                senderService.preStartSender()
                projectionManager =
                    activity?.getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                val projectionIntent = projectionManager.createScreenCaptureIntent()
                activity?.startForegroundService(projectionIntent)
                projectionLauncher.launch(projectionIntent)
            } else {
                val ip = receiverIpEdit.text.toString()
                senderService.startSender(ip, null)
            }
        }
    }

    private fun askForRecordAudioPermission(): Boolean = when {
        ContextCompat.checkSelfPermission(
            requireActivity(),
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED -> {
            // Permission already granted.
            true
        }
        shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO) -> {
            AlertDialog.Builder(requireActivity()).apply {
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
}
