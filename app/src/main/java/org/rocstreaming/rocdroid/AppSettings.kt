package org.rocstreaming.rocdroid

import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey

data class AppSettings(
    val receiverIp: String = DEFAULT_RECEIVER_IP,
    val sourcePort: Int = DEFAULT_SOURCE_PORT,
    val repairPort: Int = DEFAULT_REPAIR_PORT,
    val usePlaybackCapture: Boolean = DEFAULT_USE_PLAYBACK_CAPTURE,
    val playbackVolume: Int = PlaybackVolume.DEFAULT_PERCENT,
) {
    companion object {
        const val DEFAULT_RECEIVER_IP = "192.168.0.1"
        const val DEFAULT_SOURCE_PORT = 10001
        const val DEFAULT_REPAIR_PORT = 10002
        const val DEFAULT_USE_PLAYBACK_CAPTURE = true
    }
}

internal val KEY_RECEIVER_IP = stringPreferencesKey("receiver_ip")
internal val KEY_SOURCE_PORT = intPreferencesKey("source_port")
internal val KEY_REPAIR_PORT = intPreferencesKey("repair_port")
internal val KEY_PLAYBACK_CAPTURE = booleanPreferencesKey("playback_capture")
internal val KEY_PLAYBACK_VOLUME = intPreferencesKey("playback_volume")

internal fun Preferences.toAppSettings(): AppSettings =
    AppSettings(
        receiverIp = this[KEY_RECEIVER_IP] ?: AppSettings.DEFAULT_RECEIVER_IP,
        sourcePort = this[KEY_SOURCE_PORT] ?: AppSettings.DEFAULT_SOURCE_PORT,
        repairPort = this[KEY_REPAIR_PORT] ?: AppSettings.DEFAULT_REPAIR_PORT,
        usePlaybackCapture = this[KEY_PLAYBACK_CAPTURE] ?: AppSettings.DEFAULT_USE_PLAYBACK_CAPTURE,
        playbackVolume =
            PlaybackVolume.clamp(
                this[KEY_PLAYBACK_VOLUME] ?: PlaybackVolume.DEFAULT_PERCENT,
            ),
    )
