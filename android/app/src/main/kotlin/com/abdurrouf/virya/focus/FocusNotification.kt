package com.abdurrouf.virya.focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import com.abdurrouf.virya.MainActivity
import com.abdurrouf.virya.R

/**
 * Notifikasi heads-up prioritas tinggi saat batas waktu harian aplikasi habis.
 * Berjalan tanpa butuh izin Aksesibilitas, sehingga aman untuk m-Banking (SeaBank, BCA, dll).
 */
object FocusNotification {
    private const val CHANNEL_ID = "focus_limits"
    private const val NOTIFY_THROTTLE_MS = 15 * 60 * 1000L // maks sekali per 15 menit per aplikasi
    private val lastNotifiedAt = HashMap<String, Long>()

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

    fun notifyLimitReached(
        context: Context,
        packageName: String,
        label: String,
        limitMinutes: Int,
    ) {
        val now = SystemClock.elapsedRealtime()
        val last = lastNotifiedAt[packageName] ?: 0L
        if (now - last < NOTIFY_THROTTLE_MS) return
        lastNotifiedAt[packageName] = now

        ensureChannel(context)

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            packageName.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
        }

        val notification = builder
            .setSmallIcon(R.drawable.ic_task_quick)
            .setContentTitle("⚠️ Waktu Habis: $label")
            .setContentText("Batas harian $limitMinutes menit telah tercapai. Saatnya istirahat!")
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        manager(context).notify(packageName.hashCode(), notification)
    }
}

