package org.rocstreaming.rocdroid.fragment

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.SeekBar
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import kotlinx.coroutines.launch
import org.rocstreaming.rocdroid.AppSettings
import org.rocstreaming.rocdroid.AudioLevel
import org.rocstreaming.rocdroid.PlaybackVolume
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.SenderReceiverService
import org.rocstreaming.rocdroid.SettingsRepository
import org.rocstreaming.rocdroid.StreamKind
import org.rocstreaming.rocdroid.StreamStatus
import org.rocstreaming.rocdroid.component.CopyBlock
import org.rocstreaming.rocdroid.databinding.ReceiverFragmentBinding
import org.rocstreaming.rocdroid.formatElapsed
import java.net.NetworkInterface
import kotlin.math.roundToInt

private const val LOG_TAG = "[rocdroid.fragment.ReceiverFragment]"

class ReceiverFragment : Fragment() {
    private lateinit var binding: ReceiverFragmentBinding
    private lateinit var receiverService: SenderReceiverService
    private lateinit var settingsRepository: SettingsRepository
    private var lastAppliedPorts: Pair<Int, Int>? = null
    private var displayedLevel = 0f

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        Log.d(LOG_TAG, "Create Receiver Fragment View")

        binding = ReceiverFragmentBinding.inflate(inflater, container, false)
        settingsRepository = SettingsRepository.get(requireContext())

        applyReceiverSettings(settingsRepository.settings.value)
        setupPlaybackVolume()

        val ipAddressesContainer: LinearLayout = binding.root.findViewById(R.id.IPAddresses)

        getIpAddresses().forEach {
            val copyBlock = CopyBlock(requireActivity())
            copyBlock.setText(it)

            ipAddressesContainer.addView(copyBlock)
        }

        binding.portForSource.text =
            getString(R.string.receiver_sender_port_for_source).format(3)

        binding.portForRepair.text =
            getString(R.string.receiver_sender_port_for_repair).format(4)

        binding.startReceiverButton.setOnClickListener {
            startStopReceiver()
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
                    applyReceiverSettings(settings)
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()

        if (::binding.isInitialized) refreshReceiverSettings()
    }

    private fun refreshReceiverSettings() {
        applyReceiverSettings(settingsRepository.settings.value)
    }

    private fun applyReceiverSettings(settings: AppSettings) {
        binding.sourcePortValue.setText(settings.sourcePort.toString())
        binding.repairPortValue.setText(settings.repairPort.toString())

        if (!binding.playbackVolume.isPressed) {
            binding.playbackVolume.progress = settings.playbackVolume
        }
        updatePlaybackVolumeLabel(settings.playbackVolume)

        val ports = settings.sourcePort to settings.repairPort
        if (::receiverService.isInitialized && receiverService.isReceiverAlive()) {
            receiverService.setReceiverVolume(settings.playbackVolume)
        } else if (ports != lastAppliedPorts) {
            showInactiveReceiverStatus(settings)
        }
        lastAppliedPorts = ports
    }

    private fun setupPlaybackVolume() {
        binding.playbackVolume.max = PlaybackVolume.MAX_PERCENT
        binding.playbackVolume.progress = settingsRepository.settings.value.playbackVolume
        updatePlaybackVolumeLabel(binding.playbackVolume.progress)

        binding.playbackVolume.setOnSeekBarChangeListener(
            object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(
                    seekBar: SeekBar?,
                    progress: Int,
                    fromUser: Boolean,
                ) {
                    if (!fromUser) return

                    val percent = PlaybackVolume.clamp(progress)
                    updatePlaybackVolumeLabel(percent)

                    if (::receiverService.isInitialized) {
                        receiverService.setReceiverVolume(percent)
                    }

                    lifecycleScope.launch {
                        settingsRepository.setPlaybackVolume(percent)
                    }
                }

                override fun onStartTrackingTouch(seekBar: SeekBar?) = Unit

                override fun onStopTrackingTouch(seekBar: SeekBar?) = Unit
            },
        )
    }

    private fun updatePlaybackVolumeLabel(percent: Int) {
        binding.playbackVolumeLabel.text =
            getString(R.string.receiver_playback_volume_value, percent)
    }

    private fun startStopReceiver() {
        if (receiverService.isReceiverAlive()) {
            Log.d(LOG_TAG, "Stopping Receiver")

            receiverService.stopReceiver()
        } else {
            Log.d(LOG_TAG, "Starting Receiver")

            receiverService.startReceiver()
        }
    }

    fun onServiceConnected(
        service: SenderReceiverService,
        showActiveIcon: () -> Unit,
        hideActiveIcon: () -> Unit,
    ) {
        Log.d(LOG_TAG, "Add Receiver State Changed Listener")

        receiverService = service

        receiverService.setReceiverStateChangedListeners(
            receiverChanged = { state: Boolean ->
                activity?.runOnUiThread {
                    binding.startReceiverButton.text =
                        getString(if (state) R.string.stop_receiver else R.string.start_receiver)
                    if (state) showActiveIcon() else hideActiveIcon()
                }
            },
        )

        receiverService.setReceiverStatusListener { status ->
            activity?.runOnUiThread {
                if (isAdded && view != null) updateReceiverStatus(status)
            }
        }

        if (::settingsRepository.isInitialized) {
            receiverService.setReceiverVolume(settingsRepository.settings.value.playbackVolume)
        }
    }

    private fun showInactiveReceiverStatus(settings: AppSettings) {
        updateReceiverStatus(
            StreamStatus.inactive(
                StreamKind.RECEIVER,
                "",
                settings.sourcePort,
                settings.repairPort,
            ),
        )
    }

    private fun updateReceiverStatus(status: StreamStatus) {
        val card = binding.statusCard

        card.statusText.text =
            getString(if (status.active) R.string.status_streaming else R.string.status_stopped)
        card.statusDot.setBackgroundResource(
            if (status.active) R.drawable.status_dot_active else R.drawable.status_dot_inactive,
        )
        card.statusEndpoint.text =
            getString(
                R.string.status_receiver_endpoint,
                status.sourcePort,
                status.repairPort,
            )

        if (status.active) {
            card.statusUptime.text = formatElapsed(status.elapsedMs)
            card.statusLevelRow.visibility = View.VISIBLE
            displayedLevel = maxOf(status.level, AudioLevel.decay(displayedLevel))
            card.statusLevel.progress = (displayedLevel * 100).roundToInt()
            card.statusStats.text =
                getString(R.string.status_receiver_stats, status.underruns, status.errors)
        } else {
            card.statusUptime.text = ""
            card.statusLevelRow.visibility = View.GONE
            card.statusLevel.progress = 0
            displayedLevel = 0f
            card.statusStats.text =
                if (status.underruns > 0 || status.errors > 0) {
                    getString(R.string.status_receiver_stats, status.underruns, status.errors)
                } else {
                    ""
                }
        }
    }

    private fun getIpAddresses(): List<String> {
        Log.d(LOG_TAG, "Getting Receiver IP Addresses")

        try {
            return NetworkInterface.getNetworkInterfaces().toList()
                .flatMap { it.inetAddresses.toList() }
                .filter { !it.isLoopbackAddress && !it.hostAddress!!.contains(':') }
                .map { it.hostAddress!! }
        } catch (ignored: Exception) {
        }
        return emptyList()
    }
}
