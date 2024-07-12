package org.rocstreaming.rocdroid

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import java.lang.String.format

class AboutActivity : AppCompatActivity() {
    private lateinit var sourceCodeButton: Button
    private lateinit var bugTrackerButton: Button
    private lateinit var contributorsButton: Button
    private lateinit var licenseButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_about)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        sourceCodeButton = findViewById(R.id.about_source_code)
        bugTrackerButton = findViewById(R.id.about_bug_tracker)
        contributorsButton = findViewById(R.id.about_contributors)
        licenseButton = findViewById(R.id.app_license)

        val manager = this.packageManager
        val info = manager.getPackageInfo(this.packageName, PackageManager.GET_ACTIVITIES)

        findViewById<TextView>(R.id.app_version).text = format("v%s", info.versionName)

        sourceCodeButton.setOnClickListener {
            openLink(getString(R.string.url_repo))
        }
        bugTrackerButton.setOnClickListener {
            openLink(getString(R.string.url_bugs))
        }
        contributorsButton.setOnClickListener {
            openLink(getString(R.string.url_contributors))
        }
        licenseButton.setOnClickListener {
            openLink(getString(R.string.uri_license))
        }
    }

    private fun openLink(link: String) {
        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
        startActivity(browserIntent)
    }
}
