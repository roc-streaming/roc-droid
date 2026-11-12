package org.rocstreaming.rocdroid

import android.app.Activity
import android.content.Intent
import android.content.pm.ServiceInfo
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class SenderReceiverServiceForegroundTest {
    @Test
    fun receivingNeedsMediaPlaybackType() {
        assertEquals(
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            foregroundServiceTypes(receiving = true, capturingPlayback = false),
        )
    }

    @Test
    fun capturingPlaybackNeedsMediaProjectionType() {
        assertEquals(
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            foregroundServiceTypes(receiving = false, capturingPlayback = true),
        )
    }

    @Test
    fun receivingWhileCapturingPlaybackNeedsBothTypes() {
        assertEquals(
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            foregroundServiceTypes(receiving = true, capturingPlayback = true),
        )
    }

    @Test
    fun needsNoForegroundTypeWhenNeitherApplies() {
        assertEquals(0, foregroundServiceTypes(receiving = false, capturingPlayback = false))
    }

    @Test
    fun leavesForegroundWhenCaptureConsentCannotBeUsed() {
        val service = Robolectric.buildService(SenderReceiverService::class.java).create().get()

        service.startProjectionSender("192.168.0.1", Activity.RESULT_CANCELED, Intent())

        assertTrue(shadowOf(service).isForegroundStopped)
        assertFalse(service.isSenderAlive())
    }
}
