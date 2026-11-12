package org.rocstreaming.rocdroid

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.tabs.TabLayoutMediator
import org.rocstreaming.rocdroid.adapter.ViewPagerAdapter
import org.rocstreaming.rocdroid.databinding.ActivityMainBinding
import org.rocstreaming.rocdroid.fragment.ReceiverFragment
import org.rocstreaming.rocdroid.fragment.SenderFragment

private const val LOG_TAG = "[rocdroid.MainActivity]"
private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private val senderFragment = SenderFragment()
    private val receiverFragment = ReceiverFragment()

    private lateinit var tabsTitle: Array<String>

    private lateinit var senderReceiverService: SenderReceiverService

    private val notificationPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                Log.d(LOG_TAG, "Notification permission granted")
            } else {
                Log.w(LOG_TAG, "Notification permission denied")
            }
        }

    private val senderReceiverServiceConnection =
        object : ServiceConnection {
            override fun onServiceConnected(
                componentName: ComponentName,
                binder: IBinder,
            ) {
                senderReceiverService = (binder as SenderReceiverService.LocalBinder).getService()

                senderFragment.onServiceConnected(
                    senderReceiverService,
                    { showActiveIcon(1) },
                    { hideActiveIcon(1) },
                )
                receiverFragment.onServiceConnected(
                    senderReceiverService,
                    { showActiveIcon(0) },
                    { hideActiveIcon(0) },
                )
            }

            override fun onServiceDisconnected(componentName: ComponentName) {
                senderReceiverService.removeListeners()
            }
        }

    fun showActiveIcon(tabIdx: Int) {
        binding.tabs.getTabAt(tabIdx)?.icon?.alpha = 255
    }

    fun hideActiveIcon(tabIdx: Int) {
        binding.tabs.getTabAt(tabIdx)?.icon?.alpha = 0
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(LOG_TAG, "Create Main Activity")

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        volumeControlStream = AudioManager.STREAM_MUSIC

        tabsTitle =
            arrayOf(
                getString(R.string.receiver),
                getString(R.string.sender),
            )

        val adapter =
            ViewPagerAdapter(
                supportFragmentManager,
                lifecycle,
            ).setFragments(
                receiverFragment,
                senderFragment,
            )

        binding.viewPager.adapter = adapter

        TabLayoutMediator(binding.tabs, binding.viewPager) { tab, position ->
            tab.text = tabsTitle[position]
            tab.icon = ContextCompat.getDrawable(this@MainActivity, R.drawable.round_indicator)
            tab.icon?.alpha = 0
            binding.viewPager.setCurrentItem(tab.position, true)
        }.attach()

        val serviceIntent = Intent(this, SenderReceiverService::class.java)
        bindService(serviceIntent, senderReceiverServiceConnection, BIND_AUTO_CREATE)

        // Request notification permission on Android 13+
        requestNotificationPermission()

        // Handle opening sender tab from quick settings tile
        if (intent.getBooleanExtra("open_sender_tab", false)) {
            binding.viewPager.currentItem = 1
        }
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        volumeControlStream = AudioManager.STREAM_MUSIC

        // Handle opening sender tab from quick settings tile (if app was already running)
        if (intent.getBooleanExtra("open_sender_tab", false)) {
            binding.viewPager.currentItem = 1
            intent.removeExtra("open_sender_tab")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("open_sender_tab", false)) {
            binding.viewPager.currentItem = 1
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unbindService(senderReceiverServiceConnection)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        super.onCreateOptionsMenu(menu)
        menuInflater.inflate(R.menu.menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.about -> {
                val intent = Intent(this, AboutActivity::class.java)
                startActivity(intent)

                true
            }
            else -> false
        }
    }
}
