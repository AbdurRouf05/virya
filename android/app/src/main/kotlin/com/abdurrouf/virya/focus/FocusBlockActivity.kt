package com.abdurrouf.virya.focus

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowInsetsController
import android.widget.TextView
import android.window.OnBackInvokedDispatcher
import com.abdurrouf.virya.NativeStyle
import com.abdurrouf.virya.R
import kotlin.math.roundToInt

/** Layar "Waktu habis" yang muncul saat kuota harian aplikasi terpakai. */
class FocusBlockActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_focus_block)
        applyStyle()
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

    /** Mewarnai layar sesuai style aktif di aplikasi. */
    private fun applyStyle() {
        val style = NativeStyle.colors(this)
        window.decorView.setBackgroundColor(style.paper)
        @Suppress("DEPRECATION")
        window.statusBarColor = style.paper
        @Suppress("DEPRECATION")
        window.navigationBarColor = style.paper
        setLightStatusBar(!style.dark)
        findViewById<View>(R.id.focus_block_root).setBackgroundColor(style.paper)
        findViewById<TextView>(R.id.focus_block_title).setTextColor(style.ink)
        findViewById<TextView>(R.id.focus_block_app).setTextColor(style.warn)
        findViewById<TextView>(R.id.focus_block_message).setTextColor(style.muted)
        val strokePx = (2 * resources.displayMetrics.density).roundToInt()
        findViewById<TextView>(R.id.focus_block_extend).apply {
            setTextColor(style.ink)
            background = GradientDrawable().apply {
                setColor(style.paper)
                setStroke(strokePx, style.ink)
            }
        }
        findViewById<TextView>(R.id.focus_block_close).apply {
            setTextColor(style.paper)
            setBackgroundColor(style.ink)
        }
    }

    private fun setLightStatusBar(light: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.setSystemBarsAppearance(
                if (light) WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS else 0,
                WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS,
            )
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility =
                if (light) View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR else 0
        }
    }

    private fun render() {
        val packageName = intent.getStringExtra(EXTRA_PACKAGE)
        if (packageName == null) {
            finish()
            return
        }
        val minutes = intent.getIntExtra(EXTRA_MINUTES, 0)
        val unlocks = FocusStore.unlockCount(this, packageName)
        findViewById<TextView>(R.id.focus_block_app).text =
            intent.getStringExtra(EXTRA_LABEL) ?: packageName
        findViewById<TextView>(R.id.focus_block_message).text = buildString {
            append(getString(R.string.focus_block_message, minutes))
            if (unlocks > 0) {
                append('\n')
                append(getString(R.string.focus_block_reopened, unlocks, unlocks * FocusStore.BONUS_MINUTES))
            }
        }
        val extend = findViewById<TextView>(R.id.focus_block_extend)
        extend.setOnClickListener { extendAndReturn(packageName) }
        startCountdown(extend, FocusStore.waitSeconds(unlocks))
    }

    /** "Tetap buka" baru bisa ditekan setelah jeda; makin sering dibuka, makin lama. */
    private fun startCountdown(extend: TextView, seconds: Int) {
        handler.removeCallbacksAndMessages(null)
        var left = seconds
        fun step() {
            if (left > 0) {
                extend.isEnabled = false
                extend.alpha = 0.45f
                extend.text = getString(R.string.focus_block_extend_wait, FocusStore.BONUS_MINUTES, left)
                left--
                handler.postDelayed({ step() }, 1_000L)
            } else {
                extend.isEnabled = true
                extend.alpha = 1f
                extend.text = getString(R.string.focus_block_extend, FocusStore.BONUS_MINUTES)
            }
        }
        step()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
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
