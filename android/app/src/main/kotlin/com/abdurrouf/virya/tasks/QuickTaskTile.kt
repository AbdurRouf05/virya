package com.abdurrouf.virya.tasks

import android.app.PendingIntent
import android.os.Build
import android.service.quicksettings.TileService

/** Ubin Quick Settings: membuka lembar catat cepat. */
class QuickTaskTile : TileService() {
    override fun onClick() {
        super.onClick()
        if (isLocked) unlockAndRun { open() } else open()
    }

    private fun open() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(
                PendingIntent.getActivity(
                    this,
                    3,
                    TaskIntents.quickTask(this),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
        } else {
            openLegacy()
        }
    }

    @Suppress("DEPRECATION")
    private fun openLegacy() {
        startActivityAndCollapse(TaskIntents.quickTask(this))
    }
}
