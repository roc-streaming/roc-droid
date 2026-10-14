package org.rocstreaming.rocdroid

import android.content.Context
import android.content.SharedPreferences

const val PREFS_NAME = "settings"
const val PREF_SENDER_FEC = "sender_fec"
const val PREF_RECEIVER_FEC = "receiver_fec"

fun Context.settings(): SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

/** FEC stays enabled unless the user turned it off, as the app always used FEC before. */
fun SharedPreferences.isFecEnabled(key: String): Boolean = getBoolean(key, true)
