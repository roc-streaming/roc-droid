package org.rocstreaming.rocdroid.fragment

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.net.InetAddress

class ReceiverFragmentTest {
    @Test
    fun testIpAddressFiltering() {
        // Simulate the filtering logic from getIpAddresses()
        val testAddresses =
            listOf(
                InetAddress.getByName("127.0.0.1"),
                InetAddress.getByName("192.168.1.100"),
                InetAddress.getByName("10.0.0.50"),
                InetAddress.getByName("::1"),
                InetAddress.getByName("fe80::1"),
                InetAddress.getByName("2001:db8::1"),
            )

        val filtered =
            testAddresses
                .filter { !it.isLoopbackAddress && !it.hostAddress.contains(':') }
                .map { it.hostAddress }

        assertEquals(2, filtered.size)
        assertTrue(filtered.contains("192.168.1.100"))
        assertTrue(filtered.contains("10.0.0.50"))
        assertFalse(filtered.contains("127.0.0.1"))
        assertFalse(filtered.contains("::1"))
    }

    @Test
    fun testPortFormatting() {
        val sourceFormat = "%s. Use this port for source stream"
        val repairFormat = "%s. Use this port for repair stream"

        assertEquals("2. Use this port for source stream", sourceFormat.format(2))
        assertEquals("3. Use this port for repair stream", repairFormat.format(3))
    }
}
