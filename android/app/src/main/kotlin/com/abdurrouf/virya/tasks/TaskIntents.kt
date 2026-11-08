package com.abdurrouf.virya.tasks

import android.content.Context
import android.content.Intent
import com.abdurrouf.virya.MainActivity

/** Nama aksi & extra yang dipakai bersama oleh komponen tugas. */
object TaskIntents {
    const val ACTION_QUICK_TASK = "com.abdurrouf.virya.QUICK_TASK"
    const val ACTION_CAPTURE = "com.abdurrouf.virya.tasks.CAPTURE"
    const val ACTION_DONE = "com.abdurrouf.virya.tasks.DONE"
    const val EXTRA_TASK_ID = "task_id"
    const val KEY_REPLY = "task_title"

    /** Membuka aplikasi langsung ke lembar catat cepat. */
    fun quickTask(context: Context): Intent =
        Intent(context, MainActivity::class.java)
            .setAction(ACTION_QUICK_TASK)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)

    /** Membuka aplikasi seperti biasa. */
    fun openApp(context: Context): Intent =
        Intent(context, MainActivity::class.java)
            .setAction(Intent.ACTION_MAIN)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
}
