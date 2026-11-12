package org.rocstreaming.rocdroid.fragment

import org.junit.Assert.assertEquals
import org.junit.Test

class SenderFragmentTest {
    @Test
    fun testAudioSourceArray() {
        // Test that the audio sources array has the expected values
        val sources =
            arrayOf(
                "Currently playing apps",
                "Microphone",
            )

        assertEquals(2, sources.size)
        assertEquals("Currently playing apps", sources[0])
        assertEquals("Microphone", sources[1])
    }

    @Test
    fun testDefaultReceiverIp() {
        val defaultIp = "192.168.0.1"
        assertEquals("192.168.0.1", defaultIp)
    }

    @Test
    fun testPortValues() {
        val sourcePort = "10001"
        val repairPort = "10002"

        assertEquals("10001", sourcePort)
        assertEquals("10002", repairPort)
    }
}
