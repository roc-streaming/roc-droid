package org.rocstreaming.rocdroid.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter
import org.rocstreaming.rocdroid.fragment.ReceiverFragment
import org.rocstreaming.rocdroid.fragment.SenderFragment

private const val NUM_TABS = 2

public class ViewPagerAdapter(fragmentManager: FragmentManager, lifecycle: Lifecycle) :
    FragmentStateAdapter(fragmentManager, lifecycle) {
    private lateinit var receiverFragment: ReceiverFragment
    private lateinit var senderFragment: SenderFragment

    override fun getItemCount(): Int {
        return NUM_TABS
    }

    override fun createFragment(position: Int): Fragment {
        return if (position == 0) receiverFragment else senderFragment
    }

    fun setFragments(receiver: ReceiverFragment, sender: SenderFragment): ViewPagerAdapter {
        receiverFragment = receiver
        senderFragment = sender

        return this
    }
}
