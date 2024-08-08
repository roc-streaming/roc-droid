package org.rocstreaming.connector

import Backend
import org.rocstreaming.service.SenderReceiverService

private class Connector : Backend {
  override fun getHostLanguage(): String {
    return "Kotlin"
  }

  private var senderReceiverService: SenderReceiverService = SenderReceiverService()

  override fun startReceiver() {
    senderReceiverService.startReceiver()
  }

  override fun stopReceiver() {
    senderReceiverService.stopReceiver()
  }

  override fun isReceiverAlive(): Boolean {
    return senderReceiverService.isReceiverAlive()
  }

  override fun startSender(ip: String) {
    senderReceiverService.startSender(ip, null)
  }

  override fun stopSender() {
    senderReceiverService.stopSender()
  }

  override fun isSenderAlive(): Boolean {
    return senderReceiverService.isSenderAlive()
  }
}