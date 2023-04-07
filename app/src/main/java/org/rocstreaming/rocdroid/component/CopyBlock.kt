package org.rocstreaming.rocdroid.component

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Handler
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import org.rocstreaming.rocdroid.R

private const val LOG_TAG = "[rocdroid.component.CopyBlock]"

class CopyBlock : ConstraintLayout {
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)

    private val textBlock: EditText?

    init {
        Log.d(LOG_TAG, "Init Copy Block")

        val view: View = inflate(context, R.layout.copy_block_component, this)
        textBlock = view.findViewById<EditText>(R.id.block_label)

        view.findViewById<ConstraintLayout>(R.id.copy_block).setOnClickListener {
            setClipboard(context, textBlock.text, it.findViewById(R.id.copy_icon))
        }
    }

    fun setText(text: String) {
        Log.d(LOG_TAG, String.format("Setting Text To Copy Block: %s", text))

        textBlock?.setText(text)
    }

    private fun setClipboard(context: Context, text: CharSequence, icon: ImageView) {
        Log.d(LOG_TAG, String.format("Copying Text: %s", text))

        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        val clipData = ClipData.newPlainText("text", text)
        clipboardManager.setPrimaryClip(clipData)

        animateImageChange(context, icon, R.drawable.ic_done)
        Handler().postDelayed({
            animateImageChange(context, icon, R.drawable.ic_copy)
        }, 1000)
    }

    private fun animateImageChange(c: Context?, icon: ImageView, image: Int) {
        Log.d(LOG_TAG, String.format("Changing image in Copy Block"))

        val animOut: Animation = AnimationUtils.loadAnimation(c, android.R.anim.fade_out)
        val animIn: Animation = AnimationUtils.loadAnimation(c, android.R.anim.fade_in)
        animOut.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation?) {}
            override fun onAnimationRepeat(animation: Animation?) {}
            override fun onAnimationEnd(animation: Animation?) {
                icon.setImageResource(image)
                icon.startAnimation(animIn)
            }
        })
        icon.startAnimation(animOut)
    }
}
