package org.rocstreaming.rocdroid

import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Connects the main screen to [SenderReceiverService].
 *
 * The activity and its fragments are recreated on rotation and when the app is restored after
 * being killed in the background, so none of them can own the connection or be handed the
 * service directly: the instances that end up on screen are not necessarily the ones that
 * were handed it. This view model outlives them. It is the service's only listener and
 * republishes what the service reports as flows that whichever instances are currently on
 * screen collect.
 */
class StreamServiceViewModel(application: Application) : AndroidViewModel(application) {
    private val _service = MutableStateFlow<SenderReceiverService?>(null)

    /** The connected service, or null while the connection is being established. */
    val service: StateFlow<SenderReceiverService?> = _service.asStateFlow()

    private val _receiverRunning = MutableStateFlow(false)
    val receiverRunning: StateFlow<Boolean> = _receiverRunning.asStateFlow()

    private val _senderRunning = MutableStateFlow(false)
    val senderRunning: StateFlow<Boolean> = _senderRunning.asStateFlow()

    private val _receiverStatus = eventFlow<StreamStatus>()
    val receiverStatus: SharedFlow<StreamStatus> = _receiverStatus.asSharedFlow()

    private val _senderStatus = eventFlow<StreamStatus>()
    val senderStatus: SharedFlow<StreamStatus> = _senderStatus.asSharedFlow()

    private val _senderErrors = eventFlow<String>()
    val senderErrors: SharedFlow<String> = _senderErrors.asSharedFlow()

    private val connection =
        object : ServiceConnection {
            override fun onServiceConnected(
                componentName: ComponentName,
                binder: IBinder,
            ) {
                val connected = (binder as SenderReceiverService.LocalBinder).getService()

                connected.setReceiverStateChangedListeners { running -> _receiverRunning.value = running }
                connected.setSenderStateChangedListeners { running -> _senderRunning.value = running }
                connected.setReceiverStatusListener { status -> _receiverStatus.tryEmit(status) }
                connected.setSenderStatusListener { status -> _senderStatus.tryEmit(status) }
                connected.setSenderErrorCallback { message -> _senderErrors.tryEmit(message) }

                // A stream may already be running, e.g. one started from a quick settings tile.
                _receiverRunning.value = connected.isReceiverAlive()
                _senderRunning.value = connected.isSenderAlive()
                _service.value = connected
            }

            override fun onServiceDisconnected(componentName: ComponentName) {
                _service.value?.removeListeners()
                _service.value = null
            }
        }

    init {
        application.bindService(
            Intent(application, SenderReceiverService::class.java),
            connection,
            Context.BIND_AUTO_CREATE,
        )
    }

    override fun onCleared() {
        _service.value?.removeListeners()
        _service.value = null
        getApplication<Application>().unbindService(connection)
    }

    // The service reports from its audio threads, which must never wait for the UI: keep only
    // the latest report and drop it if nobody is listening.
    private fun <T> eventFlow() = MutableSharedFlow<T>(extraBufferCapacity = 1, onBufferOverflow = BufferOverflow.DROP_OLDEST)
}
