package org.rocstreaming.rocdroid

import org.junit.Assert.assertEquals
import org.junit.Test

class PlaybackVolumeTest {
    @Test
    fun zeroPercentIsMuted() {
        assertEquals(0f, PlaybackVolume.toGain(0), 0.0001f)
    }

    @Test
    fun fiftyPercentIsHalfGain() {
        assertEquals(0.5f, PlaybackVolume.toGain(50), 0.0001f)
    }

    @Test
    fun fullPercentIsUnityGain() {
        assertEquals(1f, PlaybackVolume.toGain(100), 0.0001f)
    }

    @Test
    fun percentBelowRangeIsClampedToMute() {
        assertEquals(0f, PlaybackVolume.toGain(-20), 0.0001f)
    }

    @Test
    fun percentAboveRangeIsClampedToUnity() {
        assertEquals(1f, PlaybackVolume.toGain(150), 0.0001f)
    }

    @Test
    fun clampKeepsPercentInRange() {
        assertEquals(0, PlaybackVolume.clamp(-1))
        assertEquals(40, PlaybackVolume.clamp(40))
        assertEquals(100, PlaybackVolume.clamp(101))
    }
}
