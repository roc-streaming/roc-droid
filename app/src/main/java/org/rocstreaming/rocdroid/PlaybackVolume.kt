package org.rocstreaming.rocdroid

object PlaybackVolume {
    const val MIN_PERCENT = 0
    const val MAX_PERCENT = 100
    const val DEFAULT_PERCENT = 100

    fun clamp(percent: Int): Int = percent.coerceIn(MIN_PERCENT, MAX_PERCENT)

    fun toGain(percent: Int): Float = clamp(percent).toFloat() / MAX_PERCENT
}
