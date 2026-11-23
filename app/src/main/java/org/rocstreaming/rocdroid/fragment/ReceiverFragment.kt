package org.rocstreaming.rocdroid.fragment

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.fragment.app.Fragment
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.SenderReceiverService
import org.rocstreaming.rocdroid.component.CopyBlock
import java.net.NetworkInterface

private const val LOG_TAG = "[rocdroid.fragment.ReceiverFragment]"

private data class OutputDeviceOption(
    val id: Int,
    val label: String,
    val address: String = ""
)

class ReceiverFragment : Fragment() {

    private lateinit var receiverService: SenderReceiverService
    private lateinit var latencyInput: EditText
    private lateinit var outputDeviceLabel: TextView

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Log.d(LOG_TAG, "Create Receiver Fragment View")

        val view = inflater.inflate(R.layout.receiver_fragment, container, false)

        latencyInput = view.findViewById(R.id.receiverLatency)
        latencyInput.setText(
            requireActivity().getSharedPreferences("settings", Context.MODE_PRIVATE)
                .getInt("receiver_latency_ms", 60).coerceIn(20, 200).toString()
        )

        outputDeviceLabel = view.findViewById(R.id.receiver_output_device)
        updateOutputDeviceLabel()

        val outputDeviceDialogButton: ConstraintLayout =
            view.findViewById(R.id.receiver_output_device_dialog_button)
        outputDeviceDialogButton.setOnClickListener {
            showOutputDeviceDialog()
        }

        view.findViewById<CopyBlock>(R.id.sourcePortValue)?.setText("10001")
        view.findViewById<CopyBlock>(R.id.repairPortValue)?.setText("10002")

        val ipAddressesContainer: LinearLayout = view.findViewById(R.id.IPAddresses)

        getIpAddresses().forEach {
            val copyBlock = CopyBlock(requireActivity())
            copyBlock.setText(it)

            ipAddressesContainer.addView(copyBlock)
        }

        view.findViewById<TextView>(R.id.portForSource).text =
            getString(R.string.receiver_sender_port_for_source).format(3)

        view.findViewById<TextView>(R.id.portForRepair).text =
            getString(R.string.receiver_sender_port_for_repair).format(4)

        view.findViewById<Button>(R.id.startReceiverButton).setOnClickListener {
            startStopReceiver()
        }

        return view
    }

    private fun showOutputDeviceDialog() {
        val options = getOutputDeviceOptions()
        val savedId = requireActivity().getSharedPreferences("settings", Context.MODE_PRIVATE)
            .getInt("receiver_output_device_id", 0)
        var checkedItem = options.indexOfFirst { it.id == savedId }
        if (checkedItem < 0) checkedItem = 0

        val labels = options.map { it.label }.toTypedArray<CharSequence>()
        MaterialAlertDialogBuilder(requireActivity())
            .setTitle(R.string.dialog_choose_output_device)
            .setSingleChoiceItems(labels, checkedItem) { _, which -> checkedItem = which }
            .setPositiveButton(R.string.ok) { _, _ ->
                val option = options[checkedItem]
                requireActivity().getSharedPreferences("settings", Context.MODE_PRIVATE)
                    .edit()
                    .putInt("receiver_output_device_id", option.id)
                    .apply()
                outputDeviceLabel.text = option.label
            }
            .show()
    }

    private fun getOutputDeviceOptions(): List<OutputDeviceOption> {
        val audioManager = requireActivity().getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val labeledDevices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            .mapNotNull { device ->
                deviceLabel(device)?.let {
                    OutputDeviceOption(device.id, it, device.address.orEmpty())
                }
            }
        val duplicateLabels = labeledDevices.groupingBy { it.label }.eachCount()
            .filterValues { it > 1 }.keys
        val options = mutableListOf(
            OutputDeviceOption(0, getString(R.string.receiver_output_device_system_default))
        )
        labeledDevices.forEach { device ->
            val suffix = device.address.takeLast(8)
            val label = if (device.label in duplicateLabels && suffix.isNotEmpty()) {
                "${device.label} ($suffix)"
            } else {
                device.label
            }
            options.add(OutputDeviceOption(device.id, label))
        }
        return options
    }

    private fun updateOutputDeviceLabel() {
        val savedId = requireActivity().getSharedPreferences("settings", Context.MODE_PRIVATE)
            .getInt("receiver_output_device_id", 0)
        val options = getOutputDeviceOptions()
        val selected = options.firstOrNull { it.id == savedId } ?: options.first()
        outputDeviceLabel.text = selected.label
    }

    private fun deviceLabel(device: AudioDeviceInfo): String? {
        if (device.type == AudioDeviceInfo.TYPE_TELEPHONY) return null

        val productName = device.productName?.toString().orEmpty()
        val typeLabel = getString(
            when (device.type) {
                AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> R.string.receiver_output_device_speaker
                AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> R.string.receiver_output_device_earpiece
                AudioDeviceInfo.TYPE_WIRED_HEADSET,
                AudioDeviceInfo.TYPE_WIRED_HEADPHONES -> R.string.receiver_output_device_wired_headset
                AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> R.string.receiver_output_device_bluetooth_sco
                AudioDeviceInfo.TYPE_BLUETOOTH_A2DP -> R.string.receiver_output_device_bluetooth_a2dp
                AudioDeviceInfo.TYPE_USB_DEVICE,
                AudioDeviceInfo.TYPE_USB_ACCESSORY,
                AudioDeviceInfo.TYPE_USB_HEADSET -> R.string.receiver_output_device_usb
                else -> R.string.receiver_output_device_other
            }
        )
        return if (productName.isEmpty()) typeLabel else "$productName ($typeLabel)"
    }

    private fun startStopReceiver() {
        val latency = (latencyInput.text.toString().toIntOrNull() ?: 60).coerceIn(20, 200)
        requireActivity().getSharedPreferences("settings", Context.MODE_PRIVATE)
            .edit()
            .putInt("receiver_latency_ms", latency)
            .apply()
        latencyInput.setText(latency.toString())

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
        hideActiveIcon: () -> Unit
    ) {
        Log.d(LOG_TAG, "Add Receiver State Changed Listener")

        receiverService = service

        receiverService.setReceiverStateChangedListeners(
            receiverChanged = { state: Boolean ->
                activity?.runOnUiThread {
                    activity?.findViewById<Button>(R.id.startReceiverButton)?.text =
                        getString(if (state) R.string.stop_receiver else R.string.start_receiver)
                    if (state) showActiveIcon() else hideActiveIcon()
                }
            }
        )
    }

    private fun getIpAddresses(): List<String> {
        Log.d(LOG_TAG, "Getting Receiver IP Addresses")

        try {
            return NetworkInterface.getNetworkInterfaces().toList()
                .flatMap { it.inetAddresses.toList() }
                .filter { !it.isLoopbackAddress && !it.hostAddress.contains(':') }
                .map { it.hostAddress }
        } catch (ignored: Exception) {
        }
        return emptyList()
    }
}
