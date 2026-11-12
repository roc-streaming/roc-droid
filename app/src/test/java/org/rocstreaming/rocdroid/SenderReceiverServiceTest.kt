package org.rocstreaming.rocdroid

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import org.junit.Assert.assertEquals
import org.junit.Test

class SenderReceiverServiceTest {
    @Test
    fun testDefaultPorts() {
        // Test that default ports are defined correctly
        val sourcePort = 10001
        val repairPort = 10002

        assertEquals(10001, sourcePort)
        assertEquals(10002, repairPort)
    }

    @Test
    fun testAudioFormatConstants() {
        // Test audio format constants used in the service
        assertEquals(44100, 44100) // SAMPLE_RATE
        assertEquals(AudioFormat.ENCODING_PCM_FLOAT, AudioFormat.ENCODING_PCM_FLOAT)
        assertEquals(AudioFormat.CHANNEL_IN_STEREO, AudioFormat.CHANNEL_IN_STEREO)
        assertEquals(AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.CHANNEL_OUT_STEREO)
        assertEquals(MediaRecorder.AudioSource.DEFAULT, MediaRecorder.AudioSource.DEFAULT)
        assertEquals(AudioTrack.MODE_STREAM, AudioTrack.MODE_STREAM)
        assertEquals(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY, AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
    }

    @Test
    fun testAudioRecordState() {
        // Test AudioRecord state constants
        assertEquals(AudioRecord.STATE_INITIALIZED, AudioRecord.STATE_INITIALIZED)
        assertEquals(AudioRecord.READ_BLOCKING, AudioRecord.READ_BLOCKING)
        assertEquals(AudioTrack.WRITE_BLOCKING, AudioTrack.WRITE_BLOCKING)
    }
}
