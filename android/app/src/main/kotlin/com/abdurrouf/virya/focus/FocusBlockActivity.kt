package com.abdurrouf.virya.focus

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.TextView
import android.window.OnBackInvokedDispatcher
import com.abdurrouf.virya.R

/** Layar "Waktu habis" yang muncul saat kuota harian aplikasi terpakai. */
class FocusBlockActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_focus_block)
        findViewById<View>(R.id.focus_block_close).setOnClickListener { close() }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
            ) { close() }
        }
        render()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        render()
    }

    private fun render() {
        val packageName = intent.getStringExtra(EXTRA_PACKAGE)
        if (packageName == null) {
            finish()
            return
        }
        val minutes = intent.getIntExtra(EXTRA_MINUTES, 0)
        findViewById<TextView>(R.id.focus_block_app).text =
            intent.getStringExtra(EXTRA_LABEL) ?: packageName
        findViewById<TextView>(R.id.focus_block_message).text =
            getString(R.string.focus_block_message, minutes)
        val extend = findViewById<View>(R.id.focus_block_extend)
        val canExtend = FocusStore.bonusMinutes(this, packageName) == 0
        extend.visibility = if (canExtend) View.VISIBLE else View.GONE
        extend.setOnClickListener { extendAndReturn(packageName) }
    }

    private fun extendAndReturn(packageName: String) {
        FocusStore.grantBonus(this, packageName)
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        if (launch == null) {
            close()
            return
        }
        try {
            startActivity(launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            finish()
        } catch (_: ActivityNotFoundException) {
            close()
        }
    }

    private fun close() {
        startActivity(
            Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        finish()
    }

    @Deprecated("Dipakai sampai Android 12; versi baru lewat OnBackInvokedDispatcher.")
    override fun onBackPressed() = close()

    companion object {
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_LABEL = "label"
        const val EXTRA_MINUTES = "minutes"
    }
}
