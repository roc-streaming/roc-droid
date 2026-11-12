package org.rocstreaming.rocdroid.fragment

import android.Manifest
import android.app.Activity
import android.content.Context.MEDIA_PROJECTION_SERVICE
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import kotlinx.coroutines.launch
import org.rocstreaming.rocdroid.AppSettings
import org.rocstreaming.rocdroid.AudioLevel
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.SettingsRepository
import org.rocstreaming.rocdroid.StreamKind
import org.rocstreaming.rocdroid.StreamServiceViewModel
import org.rocstreaming.rocdroid.StreamStatus
import org.rocstreaming.rocdroid.databinding.SenderFragmentBinding
import org.rocstreaming.rocdroid.formatElapsed
import kotlin.math.roundToInt

private const val LOG_TAG = "[rocdroid.fragment.SenderFragment]"

class SenderFragment : Fragment() {
    private lateinit var binding: SenderFragmentBinding
    private lateinit var selectedAudioSource: String
    private lateinit var audioSources: Array<String>
    private var selectedAudioSourceIndex: Int = 0
    private val streamService: StreamServiceViewModel by activityViewModels()
    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var projectionLauncher: ActivityResultLauncher<Intent>
    private lateinit var settingsRepository: SettingsRepository
    private var lastAppliedReceiverIp: String? = null
    private var lastStatusEndpoint: Triple<String, Int, Int>? = null
    private var displayedLevel = 0f

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        Log.d(LOG_TAG, "Create Sender Fragment View")

        binding = SenderFragmentBinding.inflate(inflater, container, false)
        settingsRepository = SettingsRepository.get(requireContext())

        audioSources =
            arrayOf(
                getString(R.string.sender_audio_source_current_apps),
                getString(R.string.sender_audio_source_microphone),
            )

        applySenderSettings(settingsRepository.settings.value)

        binding.audioSource.text = audioSources[selectedAudioSourceIndex]

        binding.portForSource.text =
            getString(R.string.receiver_sender_port_for_source).format(2)
        binding.portForRepair.text =
            getString(R.string.receiver_sender_port_for_repair).format(3)

        binding.audioSourceDialogButton.setOnClickListener {
            showAudioSourcesDialog()
        }

        binding.editSourcePort.setOnClickListener {
            showPortDialog(true)
        }

        binding.editRepairPort.setOnClickListener {
            showPortDialog(false)
        }

        binding.startSenderButton.setOnClickListener {
            startStopSender()
        }

        projectionLauncher =
            registerForActivityResult(StartActivityForResult()) { result ->
                val data = result.data
                if (result.resultCode == Activity.RESULT_OK && data != null) {
                    val ip = binding.receiverIp.text.toString()
                    streamService.service.value?.startProjectionSender(ip, result.resultCode, data)
                }
            }

        requestPermissionLauncher =
            registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
                if (isGranted) {
                    AlertDialog.Builder(requireActivity()).apply {
                        setTitle(R.string.allow_mic_title)
                        setMessage(getString(R.string.allow_mic_ok_message))
                        setCancelable(false)
                        setPositiveButton(R.string.ok) { _, _ -> startStopSender() }
                    }.show()
                }
            }

        return binding.root
    }

    override fun onViewCreated(
        view: View,
        savedInstanceState: Bundle?,
    ) {
        super.onViewCreated(view, savedInstanceState)

        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                settingsRepository.settings.collect { settings ->
                    applySenderSettings(settings)
                }
            }
        }

        // These follow the service for as long as the view exists, not only while it is
        // visible, so that the final state of a stream that ends in the background is shown.
        viewLifecycleOwner.lifecycleScope.launch {
            streamService.senderRunning.collect { running ->
                binding.startSenderButton.text =
                    getString(if (running) R.string.stop_sender else R.string.start_sender)
            }
        }
        viewLifecycleOwner.lifecycleScope.launch {
            streamService.senderErrors.collect { errorMessage ->
                AlertDialog.Builder(requireActivity()).apply {
                    setTitle(getString(R.string.invalid_ip_title))
                    setMessage(errorMessage)
                    setCancelable(false)
                    setPositiveButton(R.string.ok) { _, _ -> }
                }.show()
            }
        }
        viewLifecycleOwner.lifecycleScope.launch {
            streamService.senderStatus.collect { status -> updateSenderStatus(status) }
        }
    }

    private fun applySenderSettings(settings: AppSettings) {
        binding.sourcePortValue.setText(settings.sourcePort.toString())
        binding.repairPortValue.setText(settings.repairPort.toString())

        val currentIp = binding.receiverIp.text.toString()
        if (currentIp.isBlank() || currentIp == lastAppliedReceiverIp) {
            binding.receiverIp.setText(settings.receiverIp)
        }
        lastAppliedReceiverIp = settings.receiverIp

        val endpoint = Triple(settings.receiverIp, settings.sourcePort, settings.repairPort)
        val endpointChanged = endpoint != lastStatusEndpoint
        lastStatusEndpoint = endpoint

        if (streamService.service.value?.isSenderAlive() != true && endpointChanged) {
            showInactiveSenderStatus(settings)
        }
    }

    private fun showInactiveSenderStatus(settings: AppSettings = settingsRepository.settings.value) {
        updateSenderStatus(
            StreamStatus.inactive(
                StreamKind.SENDER,
                settings.receiverIp,
                settings.sourcePort,
                settings.repairPort,
            ),
        )
    }

    private fun updateSenderStatus(status: StreamStatus) {
        val card = binding.statusCard

        card.statusText.text =
            getString(if (status.active) R.string.status_streaming else R.string.status_stopped)
        card.statusDot.setBackgroundResource(
            if (status.active) R.drawable.status_dot_active else R.drawable.status_dot_inactive,
        )
        card.statusEndpoint.text =
            getString(
                R.string.status_sender_endpoint,
                status.host,
                status.sourcePort,
                status.repairPort,
            )

        if (status.active) {
            card.statusUptime.text = formatElapsed(status.elapsedMs)
            card.statusLevelRow.visibility = View.VISIBLE
            displayedLevel = maxOf(status.level, AudioLevel.decay(displayedLevel))
            card.statusLevel.progress = (displayedLevel * 100).roundToInt()
            card.statusStats.text = getString(R.string.status_sender_stats, status.errors)
        } else {
            card.statusUptime.text = ""
            card.statusLevelRow.visibility = View.GONE
            card.statusLevel.progress = 0
            displayedLevel = 0f
            card.statusStats.text =
                if (status.errors > 0) getString(R.string.status_sender_stats, status.errors) else ""
        }
    }

    private fun showAudioSourcesDialog() {
        Log.d(LOG_TAG, "Showing Select Audio Source Dialog")

        selectedAudioSource = audioSources[selectedAudioSourceIndex]
        MaterialAlertDialogBuilder(requireActivity()).setTitle(R.string.dialog_choose_audio_source)
            .setSingleChoiceItems(audioSources, selectedAudioSourceIndex) { _, which ->
                selectedAudioSourceIndex = which
                selectedAudioSource = audioSources[which]
            }.setPositiveButton("Ok") { _, _ ->
                Log.d(LOG_TAG, String.format("Selected Audio Source: %s", selectedAudioSource))

                binding.audioSource.text = selectedAudioSource
            }.setNegativeButton("Cancel") { dialog, _ ->
                Log.d(LOG_TAG, "Dismiss Audio Source Dialog")

                dialog.dismiss()
            }.show()
    }

    private fun showPortDialog(isSourcePort: Boolean) {
        val title = if (isSourcePort) getString(R.string.dialog_source_port) else getString(R.string.dialog_repair_port)
        val settings = settingsRepository.settings.value
        val currentPort = if (isSourcePort) settings.sourcePort else settings.repairPort
        val otherPort = if (isSourcePort) settings.repairPort else settings.sourcePort
        val input =
            android.widget.EditText(requireActivity()).apply {
                inputType = android.text.InputType.TYPE_CLASS_NUMBER
                setText(currentPort.toString())
                selectAll()
            }

        AlertDialog.Builder(requireActivity())
            .setTitle(title)
            .setView(input)
            .setPositiveButton(R.string.ok) { _, _ ->
                val newPort = input.text.toString().toIntOrNull()
                if (newPort != null && AppSettings.isValidPort(newPort, otherPort)) {
                    if (isSourcePort) {
                        binding.sourcePortValue.setText(newPort.toString())
                    } else {
                        binding.repairPortValue.setText(newPort.toString())
                    }

                    lifecycleScope.launch {
                        if (isSourcePort) {
                            settingsRepository.setSourcePort(newPort)
                        } else {
                            settingsRepository.setRepairPort(newPort)
                        }
                    }
                } else {
                    Toast.makeText(
                        requireContext(),
                        getString(R.string.invalid_port_message, AppSettings.MIN_PORT, AppSettings.MAX_PORT),
                        Toast.LENGTH_LONG,
                    ).show()
                }
            }
            .setNegativeButton(R.string.cancel) { dialog, _ -> dialog.dismiss() }
            .show()
    }

    fun isUsePlayback(): Boolean {
        return binding.audioSource.text == audioSources[0]
    }

    private fun startStopSender() {
        // Null only for the instant before the service connection is established.
        val senderService = streamService.service.value ?: return

        if (senderService.isSenderAlive()) {
            Log.d(LOG_TAG, "Stopping Sender")

            senderService.stopSender()
            return
        }

        Log.d(LOG_TAG, "Starting Sender")

        val ip = binding.receiverIp.text.toString()
        val usePlayback = isUsePlayback()

        lifecycleScope.launch {
            settingsRepository.setSenderConfig(ip, usePlayback)

            if (!askForRecordAudioPermission()) return@launch

            if (usePlayback) {
                // Only ask here. The service goes to the foreground and takes the projection
                // once the user has agreed; Android 14+ refuses it any earlier.
                val projectionManager =
                    activity?.getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                val projectionIntent = projectionManager.createScreenCaptureIntent()
                projectionLauncher.launch(projectionIntent)
            } else {
                senderService.startSender(ip, null)
            }
        }
    }

    private fun askForRecordAudioPermission(): Boolean =
        when {
            ContextCompat.checkSelfPermission(
                requireActivity(),
                Manifest.permission.RECORD_AUDIO,
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
