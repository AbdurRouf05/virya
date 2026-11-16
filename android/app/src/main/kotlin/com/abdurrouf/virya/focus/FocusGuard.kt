package com.abdurrouf.virya.focus

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings

/**
 * Aturan bersama untuk kedua penjaga: layanan Aksesibilitas dan
 * [FocusGuardService] (tampil di atas aplikasi lain).
 */
object FocusGuard {
    private const val MILLIS_PER_MINUTE = 60_000L

    /** Sisa peringatan sebelum waktu habis. */
    const val WARN_BEFORE_MS = 60_000L

    /** Sisa milidetik hari ini, atau null bila paket tidak dibatasi. */
    fun remainingMs(context: Context, packageName: String): Long? {
        val limit = FocusStore.limitFor(context, packageName)?.takeIf { it.enabled } ?: return null
        val allowedMs =
            (limit.dailyMinutes + FocusStore.bonusMinutes(context, packageName)) * MILLIS_PER_MINUTE
        return allowedMs - FocusUsage.usedTodayMs(context, packageName)
    }

    /** Membuka layar "Waktu habis" untuk [packageName]. */
    fun showBlock(context: Context, packageName: String) {
        val limit = FocusStore.limitFor(context, packageName) ?: return
        context.startActivity(
            Intent(context, FocusBlockActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra(FocusBlockActivity.EXTRA_PACKAGE, limit.packageName)
                .putExtra(FocusBlockActivity.EXTRA_LABEL, limit.label)
                .putExtra(FocusBlockActivity.EXTRA_MINUTES, limit.dailyMinutes),
        )
    }

    /**
     * Penghalang rutinitas saat [packageName] baru dibuka. Dilewati bila
     * jatahnya sudah habis, karena layar "Waktu habis" lebih penting.
     */
    fun gateIfNeeded(context: Context, packageName: String): Boolean {
        val remaining = remainingMs(context, packageName)
        if (remaining != null && remaining <= 0) return false
        return FocusGate.maybeShow(context, packageName)
    }

    /** Peringatan "1 menit lagi", sekali per jatah waktu. */
    fun warnIfClose(context: Context, packageName: String, remainingMs: Long) {
        if (remainingMs !in 1..WARN_BEFORE_MS) return
        val limit = FocusStore.limitFor(context, packageName) ?: return
        FocusNotification.notifyAlmostOut(
            context,
            packageName,
            limit.label,
            FocusStore.unlockCount(context, packageName),
        )
    }

    fun isAccessibilityEnabled(context: Context): Boolean {
        val raw = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val service = ComponentName(context, FocusAccessibilityService::class.java)
        return raw.split(':').any { ComponentName.unflattenFromString(it) == service }
    }

    fun canDrawOverlays(context: Context): Boolean = Settings.canDrawOverlays(context)
}
