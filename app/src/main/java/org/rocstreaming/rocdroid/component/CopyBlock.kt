package org.rocstreaming.rocdroid.component

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import org.rocstreaming.rocdroid.R

private const val LOG_TAG = "[rocdroid.component.CopyBlock]"

class CopyBlock : ConstraintLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)

    private val textBlock: TextView?

    init {
        Log.d(LOG_TAG, "Init Copy Block")

        val view: View = inflate(context, R.layout.copy_block_component, this)

        textBlock = view.findViewById<TextView>(R.id.block_label)

        view.findViewById<ConstraintLayout>(R.id.copy_block).setOnClickListener {
            setClipboard(context, findViewById<TextView>(R.id.block_label).text.toString())
        }

        view
    }

    fun setText(text: String) {
        Log.d(LOG_TAG, String.format("Setting Text To Copy Block: %s", text))

        textBlock?.text = text
    }

    fun setClipboard(context: Context, text: String) {
        Log.d(LOG_TAG, String.format("Copying Text: %s", text))

        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        val clipData = ClipData.newPlainText("text", text)
        clipboardManager.setPrimaryClip(clipData)

        val myToast = Toast.makeText(context, "Copied!", Toast.LENGTH_SHORT)
        myToast.setGravity(Gravity.CENTER, 0, 200)
        myToast.show()
    }
}
