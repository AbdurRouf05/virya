package com.abdurrouf.virya.focus

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.View
import android.view.WindowInsetsController
import android.widget.LinearLayout
import android.widget.TextView
import android.window.OnBackInvokedDispatcher
import com.abdurrouf.virya.NativeStyle
import com.abdurrouf.virya.R
import com.abdurrouf.virya.tasks.RoutineReminder
import com.abdurrouf.virya.tasks.RoutineStore
import com.abdurrouf.virya.tasks.TaskChannel
import com.abdurrouf.virya.tasks.TaskIntents
import com.abdurrouf.virya.tasks.TaskStore
import com.abdurrouf.virya.tasks.refreshTaskSurfaces
import kotlin.math.roundToInt

/**
 * Penghalang ringan: daftar rutinitas yang belum selesai saat aplikasi pilihan
 * dibuka. "Lanjut" baru aktif setelah [WAIT_SECONDS] detik.
 */
class RoutineGateActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var style: NativeStyle.Colors

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_routine_gate)
        style = NativeStyle.colors(this)
        applyStyle()
        findViewById<View>(R.id.routine_gate_work).setOnClickListener { work() }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
            ) { goHome() }
        }
        render()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        render()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).roundToInt()

    private fun applyStyle() {
        window.decorView.setBackgroundColor(style.paper)
        @Suppress("DEPRECATION")
        window.statusBarColor = style.paper
        @Suppress("DEPRECATION")
        window.navigationBarColor = style.paper
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.setSystemBarsAppearance(
                if (style.dark) 0 else WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS,
                WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS,
            )
        }
        findViewById<View>(R.id.routine_gate_root).setBackgroundColor(style.paper)
        findViewById<TextView>(R.id.routine_gate_title).setTextColor(style.ink)
        findViewById<TextView>(R.id.routine_gate_message).setTextColor(style.muted)
        findViewById<TextView>(R.id.routine_gate_hint).setTextColor(style.muted)
        findViewById<TextView>(R.id.routine_gate_work).apply {
            setTextColor(style.paper)
            setBackgroundColor(style.ink)
        }
        findViewById<TextView>(R.id.routine_gate_continue).apply {
            setTextColor(style.ink)
            background = GradientDrawable().apply {
                setColor(style.paper)
                setStroke(dp(2), style.ink)
            }
        }
    }

    private fun render() {
        val target = intent.getStringExtra(EXTRA_PACKAGE)
        if (target == null) {
            finish()
            return
        }
        val label = intent.getStringExtra(EXTRA_LABEL) ?: target
        findViewById<TextView>(R.id.routine_gate_message).text =
            getString(R.string.routine_gate_message, label)
        if (!renderList(target)) return
        val next = findViewById<TextView>(R.id.routine_gate_continue)
        next.setOnClickListener { openTarget(target) }
        startCountdown(next, label)
    }

    /** Isi daftar; false bila sudah tidak ada yang tersisa (langsung lanjut). */
    private fun renderList(target: String): Boolean {
        val pending = RoutineStore.pending(this)
        if (pending.isEmpty()) {
            openTarget(target)
            return false
        }
        val list = findViewById<LinearLayout>(R.id.routine_gate_list)
        list.removeAllViews()
        for (r in pending) {
            list.addView(
                TextView(this).apply {
                    text = getString(R.string.routine_gate_item, r.title)
                    setTextColor(style.ink)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
                    setPadding(0, dp(10), 0, dp(10))
                    isClickable = true
                    isFocusable = true
                    setOnClickListener { markDone(r.id, target) }
                },
            )
        }
        return true
    }

    private fun markDone(id: String, target: String) {
        TaskStore.markDone(this, id)
        refreshTaskSurfaces(this)
        RoutineReminder.onDone(this, id)
        TaskChannel.notifyInboxChanged()
        renderList(target)
    }

    private fun startCountdown(next: TextView, label: String) {
        handler.removeCallbacksAndMessages(null)
        var left = WAIT_SECONDS
        fun step() {
            if (left > 0) {
                next.isEnabled = false
                next.alpha = 0.45f
                next.text = getString(R.string.routine_gate_continue_wait, label, left)
                left--
                handler.postDelayed({ step() }, 1_000L)
            } else {
                next.isEnabled = true
                next.alpha = 1f
                next.text = getString(R.string.routine_gate_continue, label)
            }
        }
        step()
    }

    private fun openTarget(target: String) {
        val launch = packageManager.getLaunchIntentForPackage(target)
        if (launch == null) {
            finish()
            return
        }
        try {
            startActivity(launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (_: ActivityNotFoundException) {
            // Aplikasinya sudah dihapus; cukup tutup penghalang.
        }
        finish()
    }

    private fun work() {
        startActivity(TaskIntents.openApp(this))
        finish()
    }

    private fun goHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    @Deprecated("Dipakai sampai Android 12; versi baru lewat OnBackInvokedDispatcher.")
    override fun onBackPressed() = goHome()

    companion object {
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_LABEL = "label"
        private const val WAIT_SECONDS = 5
    }
}
