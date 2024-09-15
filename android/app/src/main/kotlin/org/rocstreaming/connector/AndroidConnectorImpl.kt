package org.rocstreaming.connector

import AndroidConnector
import android.util.Log
import org.rocstreaming.service.SenderReceiverService

private const val LOG_TAG = "[rocdroid.Connector]"

class AndroidConnectorImpl : AndroidConnector {
    //private var senderReceiverService: SenderReceiverService = SenderReceiverService()

    override fun startReceiver() {
        Log.d(LOG_TAG, "Start Receiver")
        //senderReceiverService.startReceiver()
    }

    override fun stopReceiver() {
        Log.d(LOG_TAG, "Stop Receiver")
        //senderReceiverService.stopReceiver()
    }

    override fun isReceiverAlive(): Boolean {
        //return senderReceiverService.isReceiverAlive()
        return true
    }

    override fun startSender(ip: String) {
        Log.d(LOG_TAG, "Start Sender")
        //senderReceiverService.startSender(ip, null)
    }

    override fun stopSender() {
        Log.d(LOG_TAG, "Stop Sender")
        //senderReceiverService.stopSender()
    }

    override fun isSenderAlive(): Boolean {
        //return senderReceiverService.isSenderAlive()
        return true
    }
}
