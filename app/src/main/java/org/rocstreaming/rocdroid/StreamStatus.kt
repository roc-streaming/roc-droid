package org.rocstreaming.rocdroid

const val STREAM_STATUS_INTERVAL_MS = 250L

enum class StreamKind {
    SENDER,
    RECEIVER,
}

data class StreamStatus(
    val kind: StreamKind,
    val active: Boolean,
    val host: String = "",
    val sourcePort: Int = 0,
    val repairPort: Int = 0,
    val elapsedMs: Long = 0L,
    val level: Float = 0f,
    val underruns: Int = 0,
    val errors: Int = 0,
) {
    companion object {
        fun inactive(
            kind: StreamKind,
            host: String,
            sourcePort: Int,
            repairPort: Int,
            underruns: Int = 0,
            errors: Int = 0,
        ): StreamStatus =
            StreamStatus(
                kind = kind,
                active = false,
                host = host,
                sourcePort = sourcePort,
                repairPort = repairPort,
                underruns = underruns,
                errors = errors,
            )
    }
}

fun formatElapsed(elapsedMs: Long): String {
    val totalSeconds = (elapsedMs / 1000).coerceAtLeast(0)
    val hours = totalSeconds / 3600
    val minutes = (totalSeconds % 3600) / 60
    val seconds = totalSeconds % 60

    return if (hours > 0) {
        "%d:%02d:%02d".format(hours, minutes, seconds)
    } else {
        "%02d:%02d".format(minutes, seconds)
    }
}

class StatusThrottle(
    private val intervalMs: Long = STREAM_STATUS_INTERVAL_MS,
) {
    private var lastEmittedMs: Long? = null

    fun shouldEmit(nowMs: Long): Boolean {
        val last = lastEmittedMs
        if (last == null || nowMs - last >= intervalMs) {
            lastEmittedMs = nowMs
            return true
        }
        return false
    }
}
