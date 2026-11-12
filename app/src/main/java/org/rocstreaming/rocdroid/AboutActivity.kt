package org.rocstreaming.rocdroid

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import org.rocstreaming.rocdroid.databinding.ActivityAboutBinding
import java.lang.String.format

class AboutActivity : AppCompatActivity() {
    private lateinit var binding: ActivityAboutBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAboutBinding.inflate(layoutInflater)
        setContentView(binding.root)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        val manager = this.packageManager
        val info = manager.getPackageInfo(this.packageName, PackageManager.GET_ACTIVITIES)

        binding.appVersion.text = format("v%s", info.versionName)

        binding.aboutSourceCode.setOnClickListener {
            openLink(getString(R.string.url_repo))
        }
        binding.aboutBugTracker.setOnClickListener {
            openLink(getString(R.string.url_bugs))
        }
        binding.aboutContributors.setOnClickListener {
            openLink(getString(R.string.url_contributors))
        }
        binding.appLicense.setOnClickListener {
            openLink(getString(R.string.uri_license))
        }
    }

    private fun openLink(link: String) {
        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
        startActivity(browserIntent)
    }
}
