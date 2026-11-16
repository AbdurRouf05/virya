package com.abdurrouf.virya.focus

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
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
        worker.post {
            if (packageName != this.packageName && FocusGuard.gateIfNeeded(this, packageName)) return@post
            check()
        }
    }

    private fun defaultImePackage(): String? =
        Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
            ?.let { ComponentName.unflattenFromString(it)?.packageName }

    private fun check() {
        worker.removeCallbacks(recheck)
        val current = foreground ?: return
        if (current == packageName) return
        val remainingMs = FocusGuard.remainingMs(this, current) ?: return
        FocusGuard.warnIfClose(this, current, remainingMs)
        when {
            remainingMs > 0 ->
                worker.postDelayed(recheck, minOf(remainingMs, MAX_RECHECK_MS) + MARGIN_MS)
            isDuplicateBlock(current) -> worker.postDelayed(recheck, DUPLICATE_WINDOW_MS)
            else -> block(current)
        }
    }

    private fun isDuplicateBlock(current: String): Boolean =
        current == lastBlockPackage &&
            SystemClock.elapsedRealtime() - lastBlockAt < DUPLICATE_WINDOW_MS

    private fun block(target: String) {
        lastBlockPackage = target
        lastBlockAt = SystemClock.elapsedRealtime()
        performGlobalAction(GLOBAL_ACTION_HOME)
        // Layar utama perlu sempat tampil, kalau tidak ia menutupi layar blokir.
        worker.postDelayed({ FocusGuard.showBlock(this, target) }, HOME_SETTLE_MS)
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        worker.removeCallbacksAndMessages(null)
        thread.quitSafely()
        super.onDestroy()
    }

    private companion object {
        const val SYSTEM_UI = "com.android.systemui"
        const val MAX_RECHECK_MS = 20_000L
        const val MARGIN_MS = 250L
        const val DUPLICATE_WINDOW_MS = 2_000L
        const val HOME_SETTLE_MS = 250L
    }
}
