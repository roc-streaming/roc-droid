package org.rocstreaming.rocdroid

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.PI
import kotlin.math.sin
import kotlin.math.sqrt

class AudioLevelTest {
    @Test
    fun silenceHasZeroLevel() {
        assertEquals(0f, AudioLevel.rms(FloatArray(100)), 0.0001f)
    }

    @Test
    fun fullScaleSineHasExpectedRms() {
        val samples = FloatArray(1000) { sin(2.0 * PI * it / 100.0).toFloat() }

        assertEquals(1.0 / sqrt(2.0), AudioLevel.rms(samples).toDouble(), 0.01)
    }

    @Test
    fun outOfRangeSamplesAreClampedToOne() {
        val samples = FloatArray(10) { 2f }

        assertEquals(1f, AudioLevel.rms(samples), 0.0001f)
    }

    @Test
    fun decayReducesLevel() {
        assertEquals(0.3f, AudioLevel.decay(0.5f, 0.6f), 0.0001f)
    }
}

class ElapsedTimeTest {
    @Test
    fun formatsSeconds() {
        assertEquals("00:05", formatElapsed(5_000))
    }

    @Test
    fun formatsMinutesAndSeconds() {
        assertEquals("01:05", formatElapsed(65_000))
    }

    @Test
    fun formatsHoursMinutesAndSeconds() {
        assertEquals("1:01:01", formatElapsed(3_661_000))
    }
}

class StreamStatusTest {
    @Test
    fun inactiveStatusHasNoLiveData() {
        val status = StreamStatus.inactive(StreamKind.SENDER, "192.168.0.1", 10001, 10002)

        assertFalse(status.active)
        assertEquals("192.168.0.1", status.host)
        assertEquals(10001, status.sourcePort)
        assertEquals(10002, status.repairPort)
        assertEquals(0L, status.elapsedMs)
        assertEquals(0f, status.level, 0f)
        assertEquals(0, status.underruns)
        assertEquals(0, status.errors)
    }

    @Test
    fun inactiveStatusKeepsFinalCounters() {
        val status =
            StreamStatus.inactive(
                StreamKind.RECEIVER,
                "",
                10001,
                10002,
                underruns = 3,
                errors = 2,
            )

        assertEquals(3, status.underruns)
        assertEquals(2, status.errors)
    }
}

class StatusThrottleTest {
    @Test
    fun firstUpdateIsEmitted() {
        assertTrue(StatusThrottle().shouldEmit(1_000))
    }

    @Test
    fun updateInsideWindowIsSuppressed() {
        val throttle = StatusThrottle()

        throttle.shouldEmit(1_000)

        assertFalse(throttle.shouldEmit(1_100))
    }

    @Test
    fun updateAfterWindowIsEmitted() {
        val throttle = StatusThrottle()

        throttle.shouldEmit(1_000)

        assertTrue(throttle.shouldEmit(1_250))
    }
}
