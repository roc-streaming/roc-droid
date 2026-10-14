package org.rocstreaming.rocdroid.fragment

import android.view.View
import com.google.android.material.switchmaterial.SwitchMaterial
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.isFecEnabled
import org.rocstreaming.rocdroid.settings

/**
 * Binds the "Use FEC" switch of a sender or receiver screen to the preference [prefKey]
 * and dims the repair port hint, which is only used when FEC is enabled.
 */
internal fun bindFecSwitch(view: View, prefKey: String) {
    val prefs = view.context.settings()
    val fecSwitch = view.findViewById<SwitchMaterial>(R.id.fecSwitch)
    val repairViews = listOf<View>(
        view.findViewById(R.id.portForRepair),
        view.findViewById(R.id.repairPortValue)
    )

    fun showRepairPort(enabled: Boolean) {
        repairViews.forEach { it.alpha = if (enabled) 1f else 0.4f }
    }

    fecSwitch.isChecked = prefs.isFecEnabled(prefKey)
    showRepairPort(fecSwitch.isChecked)
    fecSwitch.setOnCheckedChangeListener { _, isChecked ->
        prefs.edit().putBoolean(prefKey, isChecked).apply()
        showRepairPort(isChecked)
    }
}
