package org.rocstreaming.rocdroid.fragment

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.SenderReceiverService
import org.rocstreaming.rocdroid.component.CopyBlock
import java.net.NetworkInterface

private const val LOG_TAG = "[rocdroid.fragment.ReceiverFragment]"

class ReceiverFragment : Fragment() {

    private lateinit var receiverService: SenderReceiverService

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Log.d(LOG_TAG, "Create Receiver Fragment View")

        val view = inflater.inflate(R.layout.receiver_fragment, container, false)

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
