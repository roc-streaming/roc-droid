package org.rocstreaming.rocdroid.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import org.rocstreaming.rocdroid.R
import org.rocstreaming.rocdroid.model.License

class LicenseAdapter(private val licenses: List<License>) :
    RecyclerView.Adapter<LicenseAdapter.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_license, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val license = licenses[position]
        holder.libraryNameTextView.text = license.libraryName
        holder.licenseTextView.text = license.licenseText
    }

    override fun getItemCount(): Int {
        return licenses.size
    }

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val libraryNameTextView: TextView = view.findViewById(R.id.libraryNameTextView)
        val licenseTextView: TextView = view.findViewById(R.id.licenseTextView)
    }
}
