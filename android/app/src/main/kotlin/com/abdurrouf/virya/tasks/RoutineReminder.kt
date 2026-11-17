package com.abdurrouf.virya.tasks

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import com.abdurrouf.virya.R
import java.util.Calendar

/**
 * Pengingat rutinitas: notifikasi di jam yang dipilih, lalu diulang tiap jam
 * sampai dicentang (paling lambat [END_MINUTE]). Hanya satu alarm yang
 * dipasang, yaitu pengingat terdekat dari semua rutinitas.
 */
object RoutineReminder {
    private const val CHANNEL_ID = "routine_reminder"
    private const val ALARM_REQUEST = 4200
    private const val NOTIFICATION_BASE = 5000
    private const val HOUR_MS = 60 * 60_000L
    private const val MINUTE_MS = 60_000L
    private const val DUE_SLACK_MS = 30_000L
    const val SNOOZE_MS = 30 * MINUTE_MS

    /** Pengingat ulang berhenti pukul 22.00. */
    private const val END_MINUTE = 22 * 60

    private fun startOfDay(millis: Long, plusDays: Int = 0): Long =
        Calendar.getInstance().apply {
            timeInMillis = millis
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.DAY_OF_YEAR, plusDays)
        }.timeInMillis

    /** Waktu pengingat berikutnya untuk [r], atau null bila tanpa jam. */
    private fun nextFor(context: Context, r: RoutineStore.Routine, pending: Boolean, now: Long): Long? {
        val minute = r.remind ?: return null
        val tomorrow = startOfDay(now, 1) + minute * MINUTE_MS
        if (!pending) return tomorrow
        val snooze = RoutineStore.snoozeUntil(context, r.id)
        if (snooze > now) return snooze
        val last = RoutineStore.lastNotified(context, r.id)
        val today = startOfDay(now)
        val end = today + maxOf(minute, END_MINUTE) * MINUTE_MS
        var slot = today + minute * MINUTE_MS
        while (slot <= last) slot += HOUR_MS
        return if (slot <= end) slot else tomorrow
    }

    /** Pasang ulang alarm sesuai data terbaru. Aman dipanggil kapan saja. */
    fun reschedule(context: Context) {
        val now = System.currentTimeMillis()
        val all = RoutineStore.all(context)
        val pendingIds = RoutineStore.pending(context).map { it.id }.toSet()
        var next = all.mapNotNull { nextFor(context, it, it.id in pendingIds, now) }.minOrNull()
        // Ringkasan di notifikasi & widget perlu diperbarui saat hari berganti.
        if (all.isNotEmpty()) next = minOf(next ?: Long.MAX_VALUE, startOfDay(now, 1) + MINUTE_MS)
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = alarmIntent(context)
        if (next == null) {
            alarms.cancel(intent)
            return
        }
        val at = maxOf(next, now + 1_000L)
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        if (exact) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
        }
    }

    /** Alarm berbunyi: kirim pengingat yang jatuh tempo, lalu pasang lagi. */
    fun onAlarm(context: Context) {
        val now = System.currentTimeMillis()
        for (r in RoutineStore.pending(context)) {
            val at = nextFor(context, r, pending = true, now = now) ?: continue
            if (at > now + DUE_SLACK_MS) continue
            RoutineStore.markNotified(context, r.id, now)
            notify(context, r)
        }
        refreshTaskSurfaces(context)
        reschedule(context)
    }

    fun onDone(context: Context, id: String) {
        manager(context).cancel(notificationId(id))
        reschedule(context)
    }

    fun onSnooze(context: Context, id: String) {
        RoutineStore.snooze(context, id, System.currentTimeMillis() + SNOOZE_MS)
        manager(context).cancel(notificationId(id))
        reschedule(context)
    }

    /** Tutup notifikasi rutinitas yang sudah tidak terbuka (dicentang di app). */
    fun clearStale(context: Context) {
        val open = RoutineStore.pending(context).map { it.id }.toSet()
        for (r in RoutineStore.all(context)) {
            if (r.id !in open) manager(context).cancel(notificationId(r.id))
        }
    }

    private fun manager(context: Context): NotificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun notificationId(id: String): Int =
        NOTIFICATION_BASE + Math.floorMod(id.hashCode(), 10_000)

    private fun alarmIntent(context: Context): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            ALARM_REQUEST,
            Intent(context, TaskReceiver::class.java).setAction(TaskIntents.ACTION_ROUTINE_ALARM),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    private fun action(context: Context, id: String, action: String, code: Int, label: String): Notification.Action {
        val pending = PendingIntent.getBroadcast(
            context,
            notificationId(id) * 4 + code,
            Intent(context, TaskReceiver::class.java)
                .setAction(action)
                .putExtra(TaskIntents.EXTRA_TASK_ID, id),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Action.Builder(
            Icon.createWithResource(context, R.drawable.ic_task_quick),
            label,
            pending,
        ).build()
    }

    private fun notify(context: Context, r: RoutineStore.Routine) {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager(context).createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    context.getString(R.string.routine_channel),
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
                .setDefaults(Notification.DEFAULT_ALL)
        }
        val open = PendingIntent.getActivity(
            context,
            notificationId(r.id) * 4,
            TaskIntents.openApp(context),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = builder
            .setSmallIcon(R.drawable.ic_task_quick)
            .setContentTitle(r.title)
            .setContentText(context.getString(R.string.routine_reminder_text))
            .setContentIntent(open)
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_REMINDER)
            .addAction(action(context, r.id, TaskIntents.ACTION_DONE, 1, context.getString(R.string.routine_action_done)))
            .addAction(action(context, r.id, TaskIntents.ACTION_ROUTINE_SNOOZE, 2, context.getString(R.string.routine_action_snooze)))
            .build()
        manager(context).notify(notificationId(r.id), notification)
    }
}
