package org.rocstreaming.rocdroid

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress

class NetworkUtilsTest {
    @Test
    fun testFilterIpv4Addresses() {
        // Test that IPv4 addresses are correctly identified
        val ipv4 = InetAddress.getByName("192.168.1.100")
        val ipv6 = InetAddress.getByName("::1")
        val ipv6Local = InetAddress.getByName("fe80::1")

        val ipv4Addr = ipv4.hostAddress
        val ipv6Addr = ipv6.hostAddress
        val ipv6LocalAddr = ipv6Local.hostAddress

        assertTrue("IPv4 should not contain colon", !ipv4Addr.contains(':'))
        assertTrue("IPv6 should contain colon", ipv6Addr.contains(':'))
        assertTrue("IPv6 link-local should contain colon", ipv6LocalAddr.contains(':'))
        assertTrue("IPv4 is Inet4Address", ipv4 is Inet4Address)
        assertTrue("IPv6 is Inet6Address", ipv6 is Inet6Address)
    }

    @Test
    fun testLoopbackFiltering() {
        val loopback = InetAddress.getByName("127.0.0.1")
        val nonLoopback = InetAddress.getByName("192.168.1.100")

        assertTrue("Loopback should be detected", loopback.isLoopbackAddress)
        assertFalse("Non-loopback should not be detected as loopback", nonLoopback.isLoopbackAddress)
    }
}
