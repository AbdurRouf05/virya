package com.abdurrouf.virya.focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.abdurrouf.virya.R

/** Notifikasi heads-up "sisa 1 menit" sebelum batas waktu harian aplikasi habis. */
object FocusNotification {
    private const val CHANNEL_ID = "focus_limits"
    private val warned = HashSet<String>()

    private fun manager(context: Context): NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Peringatan Batas Fokus",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Peringatan saat batas waktu pemakaian aplikasi habis"
                enableVibration(true)
                setShowBadge(true)
            }
            manager(context).createNotificationChannel(channel)
        }
    }

    /** "Sisa 1 menit" sekali per jatah waktu (jatah awal dan tiap +5 menit). */
    fun notifyAlmostOut(context: Context, packageName: String, label: String, unlockCount: Int) {
        val key = "${FocusStore.dayKey()}|$packageName|$unlockCount"
        synchronized(warned) {
            if (!warned.add(key)) return
        }
        ensureChannel(context)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
        }
        val notification = builder
            .setSmallIcon(R.drawable.ic_task_quick)
            .setContentTitle(context.getString(R.string.focus_warn_title, label))
            .setContentText(context.getString(R.string.focus_warn_text))
            .setAutoCancel(true)
            .apply { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) setTimeoutAfter(WARN_TIMEOUT_MS) }
            .build()
        manager(context).notify(packageName.hashCode() + 1, notification)
    }

    private const val WARN_TIMEOUT_MS = 90_000L
}
