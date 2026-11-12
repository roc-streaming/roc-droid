package org.rocstreaming.rocdroid

import kotlin.math.sqrt

object AudioLevel {
    fun rms(samples: FloatArray): Float {
        if (samples.isEmpty()) return 0f

        var sum = 0.0
        for (sample in samples) {
            val value = sample.toDouble()
            sum += value * value
        }

        return sqrt(sum / samples.size).coerceIn(0.0, 1.0).toFloat()
    }

    fun decay(
        previous: Float,
        factor: Float = 0.6f,
    ): Float = (previous * factor).coerceIn(0f, 1f)
}
