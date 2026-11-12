package org.rocstreaming.rocdroid.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter
import org.rocstreaming.rocdroid.fragment.ReceiverFragment
import org.rocstreaming.rocdroid.fragment.SenderFragment

private const val NUM_TABS = 2

class ViewPagerAdapter(fragmentManager: FragmentManager, lifecycle: Lifecycle) :
    FragmentStateAdapter(fragmentManager, lifecycle) {
    override fun getItemCount(): Int {
        return NUM_TABS
    }

    // Always hand out new instances. When the activity is recreated Android restores the
    // previous fragments by itself and does not call this, so instances created and kept
    // elsewhere would never be the ones on screen.
    override fun createFragment(position: Int): Fragment {
        return if (position == 0) ReceiverFragment() else SenderFragment()
    }
}
