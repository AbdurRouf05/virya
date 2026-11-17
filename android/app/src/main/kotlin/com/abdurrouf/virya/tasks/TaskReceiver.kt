package com.abdurrouf.virya.tasks

import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.abdurrouf.virya.focus.FocusGuardService

/**
 * Menerima balasan notifikasi, centang widget & pengingat rutinitas, alarm
 * rutinitas, dan peristiwa boot/update/ganti jam.
 */
class TaskReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            TaskIntents.ACTION_CAPTURE -> {
                val text = RemoteInput.getResultsFromIntent(intent)
                    ?.getCharSequence(TaskIntents.KEY_REPLY)
                    ?.toString()
                val saved = TaskStore.capture(context, text)
                // Tetap dipasang ulang walau kosong, agar indikator kirim berhenti.
                refreshTaskSurfaces(context, saved)
                if (saved != null) TaskChannel.notifyInboxChanged()
            }
            TaskIntents.ACTION_DONE -> {
                val id = intent.getStringExtra(TaskIntents.EXTRA_TASK_ID) ?: return
                TaskStore.markDone(context, id)
                refreshTaskSurfaces(context)
                RoutineReminder.onDone(context, id)
                TaskChannel.notifyInboxChanged()
            }
            TaskIntents.ACTION_ROUTINE_SNOOZE -> {
                val id = intent.getStringExtra(TaskIntents.EXTRA_TASK_ID) ?: return
                RoutineReminder.onSnooze(context, id)
            }
            TaskIntents.ACTION_ROUTINE_ALARM -> RoutineReminder.onAlarm(context)
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> RoutineReminder.reschedule(context)
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                refreshTaskSurfaces(context)
                RoutineReminder.reschedule(context)
                FocusGuardService.sync(context)
            }
        }
    }
}
