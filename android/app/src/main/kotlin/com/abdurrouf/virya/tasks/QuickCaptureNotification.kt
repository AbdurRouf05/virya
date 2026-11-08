package com.abdurrouf.virya.tasks

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import com.abdurrouf.virya.R

/** Notifikasi permanen dengan kolom balas untuk mencatat tugas. */
object QuickCaptureNotification {
    private const val CHANNEL_ID = "quick_task"
    private const val NOTIFICATION_ID = 4100

    private fun manager(context: Context): NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun builder(context: Context): Notification.Builder {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            return Notification.Builder(context)
                .setPriority(Notification.PRIORITY_LOW)
        }
        manager(context).createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Catat cepat tugas",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { setShowBadge(false) },
        )
        return Notification.Builder(context, CHANNEL_ID)
    }

    private fun replyAction(context: Context): Notification.Action {
        val intent = Intent(context, TaskReceiver::class.java)
            .setAction(TaskIntents.ACTION_CAPTURE)
        val pending = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )
        val input = RemoteInput.Builder(TaskIntents.KEY_REPLY)
            .setLabel("Tugas baru")
            .build()
        return Notification.Action.Builder(
            Icon.createWithResource(context, R.drawable.ic_task_quick),
            "Tambah",
            pending,
        ).addRemoteInput(input).build()
    }

    /** [saved] = judul yang baru tersimpan, ditampilkan sebagai konfirmasi. */
    fun show(context: Context, saved: String? = null) {
        val count = TaskStore.visible(context).size
        val summary = if (count == 0) "Tidak ada tugas hari ini" else "$count tugas hari ini"
        val open = PendingIntent.getActivity(
            context,
            0,
            TaskIntents.openApp(context),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = builder(context)
            .setSmallIcon(R.drawable.ic_task_quick)
            .setContentTitle(if (saved != null) "Tersimpan: $saved" else "Catat tugas")
            .setContentText(summary)
            .setContentIntent(open)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .addAction(replyAction(context))
            .build()
        manager(context).notify(NOTIFICATION_ID, notification)
    }

    fun cancel(context: Context) {
        manager(context).cancel(NOTIFICATION_ID)
    }
}
