package org.rocstreaming.rocdroid.fragment

import android.os.Bundle
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

class ReceiverFragment : Fragment() {

    private lateinit var receiverService: SenderReceiverService

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
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
            getText(R.string.receiver_sender_port_for_source).toString().format(3)

        view.findViewById<TextView>(R.id.portForRepair).text =
            getText(R.string.receiver_sender_port_for_repair).toString().format(4)

        view.findViewById<Button>(R.id.startReceiverButton).setOnClickListener {
            startStopReceiver(view)
        }

        return view
    }

    fun startStopReceiver(@Suppress("UNUSED_PARAMETER") view: View) {
        if (receiverService.isReceiverAlive()) {
            receiverService.stopReceiver()
        } else {
            receiverService.startReceiver()
        }
    }

    fun onServiceConnected(
        service: SenderReceiverService,
        showActiveIcon: (Int) -> Unit,
        hideActiveIcon: (Int) -> Unit
    ) {
        receiverService = service

        receiverService.setReceiverStateChangedListeners(
            receiverChanged = { state: Boolean ->
                activity?.runOnUiThread {
                    activity?.findViewById<Button>(R.id.startReceiverButton)?.text =
                        getText(if (state) R.string.stop_receiver else R.string.start_receiver)
                    if (state) showActiveIcon(0) else hideActiveIcon(0)
                }
            }
        )
    }

    private fun getIpAddresses(): List<String> {
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
