package org.rocstreaming.rocdroid

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.rocstreaming.rocdroid.adapter.LicenseAdapter
import org.rocstreaming.rocdroid.model.License

class LibraryActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_library)

        val recyclerView = findViewById<RecyclerView>(R.id.licenseRecyclerView)
        val adapter = LicenseAdapter(arrayList)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter
    }

    val arrayList = listOf<License>(License("roc-droid", "org.roc-streaming.roctoolkit:roc-android:0.2.1"))
}
