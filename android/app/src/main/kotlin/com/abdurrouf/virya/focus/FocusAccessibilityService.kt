package com.abdurrouf.virya.focus

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Intent
import android.os.Handler
import android.os.HandlerThread
import android.os.SystemClock
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent

/**
 * Hanya memperhatikan aplikasi mana yang sedang di depan, lalu menutupnya bila
 * kuota harian habis. Isi layar tidak dibaca.
 */
class FocusAccessibilityService : AccessibilityService() {
    private val thread = HandlerThread("focus-guard")
    private lateinit var worker: Handler
    private val recheck = Runnable { check() }

    @Volatile
    private var foreground: String? = null
    private var lastBlockAt = 0L
    private var lastBlockPackage: String? = null

    override fun onCreate() {
        super.onCreate()
        thread.start()
        worker = Handler(thread.looper)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return
        if (packageName == SYSTEM_UI || packageName == defaultImePackage()) return
        if (packageName == foreground) return
        foreground = packageName
        worker.removeCallbacks(recheck)
        worker.post(recheck)
    }

    private fun defaultImePackage(): String? =
        Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
            ?.let { ComponentName.unflattenFromString(it)?.packageName }

    private fun check() {
        worker.removeCallbacks(recheck)
        val current = foreground ?: return
        if (current == packageName) return
        val limit = FocusStore.limitFor(this, current)?.takeIf { it.enabled } ?: return
        val allowedMs =
            (limit.dailyMinutes + FocusStore.bonusMinutes(this, current)) * MILLIS_PER_MINUTE
        val remainingMs = allowedMs - FocusUsage.usedTodayMs(this, current)
        when {
            remainingMs > 0 ->
                worker.postDelayed(recheck, minOf(remainingMs, MAX_RECHECK_MS) + MARGIN_MS)
            isDuplicateBlock(current) -> worker.postDelayed(recheck, DUPLICATE_WINDOW_MS)
            else -> block(limit)
        }
    }

    private fun isDuplicateBlock(current: String): Boolean =
        current == lastBlockPackage &&
            SystemClock.elapsedRealtime() - lastBlockAt < DUPLICATE_WINDOW_MS

    private fun block(limit: FocusStore.Limit) {
        lastBlockPackage = limit.packageName
        lastBlockAt = SystemClock.elapsedRealtime()
        performGlobalAction(GLOBAL_ACTION_HOME)
        // Layar utama perlu sempat tampil, kalau tidak ia menutupi layar blokir.
        worker.postDelayed({
            startActivity(
                Intent(this, FocusBlockActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    .putExtra(FocusBlockActivity.EXTRA_PACKAGE, limit.packageName)
                    .putExtra(FocusBlockActivity.EXTRA_LABEL, limit.label)
                    .putExtra(FocusBlockActivity.EXTRA_MINUTES, limit.dailyMinutes),
            )
        }, HOME_SETTLE_MS)
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        worker.removeCallbacksAndMessages(null)
        thread.quitSafely()
        super.onDestroy()
    }

    private companion object {
        const val SYSTEM_UI = "com.android.systemui"
        const val MILLIS_PER_MINUTE = 60_000L
        const val MAX_RECHECK_MS = 60_000L
        const val MARGIN_MS = 500L
        const val DUPLICATE_WINDOW_MS = 2_000L
        const val HOME_SETTLE_MS = 250L
    }
}
