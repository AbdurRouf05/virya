package com.abdurrouf.virya.tasks

import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Menerima balasan notifikasi, centang widget, dan peristiwa boot/update. */
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
                TaskChannel.notifyInboxChanged()
            }
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> refreshTaskSurfaces(context)
        }
    }
}
