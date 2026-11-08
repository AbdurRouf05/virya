package com.abdurrouf.virya.tasks

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.abdurrouf.virya.R

/** Widget layar utama: daftar tugas hari ini + tombol tambah. */
class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        update(context, manager, appWidgetIds)
    }

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TaskWidgetProvider::class.java),
            )
            if (ids.isNotEmpty()) update(context, manager, ids)
        }

        private fun update(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val count = TaskStore.visible(context).size
            for (id in ids) manager.updateAppWidget(id, render(context, id, count))
            @Suppress("DEPRECATION")
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list)
        }

        private fun render(context: Context, widgetId: Int, count: Int): RemoteViews {
            val adapter = Intent(context, TaskWidgetService::class.java)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            // Data unik agar tiap widget mendapat adapter sendiri.
            adapter.data = Uri.parse(adapter.toUri(Intent.URI_INTENT_SCHEME))

            val doneTemplate = PendingIntent.getBroadcast(
                context,
                0,
                Intent(context, TaskReceiver::class.java)
                    .setAction(TaskIntents.ACTION_DONE),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            val add = PendingIntent.getActivity(
                context,
                1,
                TaskIntents.quickTask(context),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val open = PendingIntent.getActivity(
                context,
                2,
                TaskIntents.openApp(context),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            return RemoteViews(context.packageName, R.layout.widget_tasks).apply {
                setTextViewText(R.id.widget_count, count.toString())
                @Suppress("DEPRECATION")
                setRemoteAdapter(R.id.widget_list, adapter)
                setEmptyView(R.id.widget_list, R.id.widget_empty)
                setPendingIntentTemplate(R.id.widget_list, doneTemplate)
                setOnClickPendingIntent(R.id.widget_add, add)
                setOnClickPendingIntent(R.id.widget_title, open)
                setOnClickPendingIntent(R.id.widget_empty, add)
            }
        }
    }
}
