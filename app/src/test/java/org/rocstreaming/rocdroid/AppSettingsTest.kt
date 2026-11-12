package org.rocstreaming.rocdroid

import androidx.datastore.preferences.core.mutablePreferencesOf
import org.junit.Assert.assertEquals
import org.junit.Test

class AppSettingsTest {
    @Test
    fun defaultsWhenPreferencesAreEmpty() {
        assertEquals(AppSettings(), mutablePreferencesOf().toAppSettings())
    }

    @Test
    fun mapsStoredValues() {
        val preferences = mutablePreferencesOf()
        preferences[KEY_RECEIVER_IP] = "10.0.0.8"
        preferences[KEY_SOURCE_PORT] = 11001
        preferences[KEY_REPAIR_PORT] = 11002
        preferences[KEY_PLAYBACK_CAPTURE] = false
        preferences[KEY_PLAYBACK_VOLUME] = 37

        assertEquals(
            AppSettings(
                receiverIp = "10.0.0.8",
                sourcePort = 11001,
                repairPort = 11002,
                usePlaybackCapture = false,
                playbackVolume = 37,
            ),
            preferences.toAppSettings(),
        )
    }

    @Test
    fun clampsStoredVolumeToValidRange() {
        val tooHigh = mutablePreferencesOf()
        tooHigh[KEY_PLAYBACK_VOLUME] = 150

        val tooLow = mutablePreferencesOf()
        tooLow[KEY_PLAYBACK_VOLUME] = -10

        assertEquals(PlaybackVolume.MAX_PERCENT, tooHigh.toAppSettings().playbackVolume)
        assertEquals(PlaybackVolume.MIN_PERCENT, tooLow.toAppSettings().playbackVolume)
    }
}
