package org.rocstreaming.rocdroid

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.google.android.material.tabs.TabLayoutMediator
import kotlinx.coroutines.launch
import org.rocstreaming.rocdroid.adapter.ViewPagerAdapter
import org.rocstreaming.rocdroid.databinding.ActivityMainBinding

private const val LOG_TAG = "[rocdroid.MainActivity]"
private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    private lateinit var tabsTitle: Array<String>

    private val streamService: StreamServiceViewModel by viewModels()

    private val notificationPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                Log.d(LOG_TAG, "Notification permission granted")
            } else {
                Log.w(LOG_TAG, "Notification permission denied")
            }
        }

    private fun setTabActive(
        tabIdx: Int,
        active: Boolean,
    ) {
        binding.tabs.getTabAt(tabIdx)?.icon?.alpha = if (active) 255 else 0
    }

    // Tab 0 is the receiver and tab 1 the sender, as in ViewPagerAdapter.
    private fun showActiveStreams() {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                launch { streamService.receiverRunning.collect { running -> setTabActive(0, running) } }
                launch { streamService.senderRunning.collect { running -> setTabActive(1, running) } }
            }
        }
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

        binding.viewPager.adapter = ViewPagerAdapter(supportFragmentManager, lifecycle)

        TabLayoutMediator(binding.tabs, binding.viewPager) { tab, position ->
            tab.text = tabsTitle[position]
            tab.icon = ContextCompat.getDrawable(this@MainActivity, R.drawable.round_indicator)
            tab.icon?.alpha = 0
            binding.viewPager.setCurrentItem(tab.position, true)
        }.attach()

        showActiveStreams()

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
