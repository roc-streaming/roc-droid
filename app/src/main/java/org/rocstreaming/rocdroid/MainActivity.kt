package org.rocstreaming.rocdroid

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.SharedPreferences
import android.media.AudioManager
import android.os.Bundle
import android.os.IBinder
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import org.rocstreaming.rocdroid.adapter.ViewPagerAdapter
import org.rocstreaming.rocdroid.fragment.ReceiverFragment
import org.rocstreaming.rocdroid.fragment.SenderFragment

class MainActivity : AppCompatActivity() {

    private lateinit var pager: ViewPager2
    private lateinit var tabs: TabLayout
    private val senderFragment = SenderFragment()
    private val receiverFragment = ReceiverFragment()

    private lateinit var tabsTitle: Array<String>

    private lateinit var prefs: SharedPreferences
    private lateinit var senderReceiverService: SenderReceiverService

    private val senderReceiverServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName, binder: IBinder) {
            senderReceiverService = (binder as SenderReceiverService.LocalBinder).getService()

            senderFragment.onServiceConnected(
                senderReceiverService,
                ::showActiveIcon,
                ::hideActiveIcon
            )
            receiverFragment.onServiceConnected(
                senderReceiverService,
                ::showActiveIcon,
                ::hideActiveIcon
            )
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            senderReceiverService.removeListeners()
        }
    }

    fun showActiveIcon(tabIdx: Int) {
        tabs.getTabAt(tabIdx)?.icon?.alpha = 255
    }

    fun hideActiveIcon(tabIdx: Int) {
        tabs.getTabAt(tabIdx)?.icon?.alpha = 0
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)
        volumeControlStream = AudioManager.STREAM_MUSIC

        pager = findViewById(R.id.viewPager)
        tabs = findViewById(R.id.tabs)

        tabsTitle = arrayOf(
            getText(R.string.receiver).toString(),
            getText(R.string.sender).toString()
        )

        val adapter = ViewPagerAdapter(
            supportFragmentManager,
            lifecycle
        ).setFragments(
            receiverFragment,
            senderFragment
        )

        pager.setAdapter(adapter)

        TabLayoutMediator(tabs, pager) { tab, position ->
            tab.text = tabsTitle[position]
            tab.icon = ContextCompat.getDrawable(this@MainActivity, R.drawable.round_indicator)
            tab.icon?.alpha = 0
            pager.setCurrentItem(tab.position, true)
        }.attach()

        prefs = getSharedPreferences("settings", android.content.Context.MODE_PRIVATE)

        val serviceIntent = Intent(this, SenderReceiverService::class.java)
        bindService(serviceIntent, senderReceiverServiceConnection, BIND_AUTO_CREATE)
    }

    override fun onResume() {
        super.onResume()
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun onDestroy() {
        super.onDestroy()
        unbindService(senderReceiverServiceConnection)
    }
}
