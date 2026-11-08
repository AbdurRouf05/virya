package com.abdurrouf.virya.tasks

import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.abdurrouf.virya.NativeStyle
import com.abdurrouf.virya.R

/** Penyedia baris untuk ListView widget tugas. */
class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        Factory(applicationContext)

    private class Factory(private val context: Context) : RemoteViewsFactory {
        private var items: List<TaskStore.WidgetTask> = emptyList()
        private var style = NativeStyle.colors(context)

        override fun onCreate() = Unit

        override fun onDataSetChanged() {
            items = TaskStore.visible(context).take(MAX_ROWS)
            style = NativeStyle.colors(context)
        }

        override fun onDestroy() {
            items = emptyList()
        }

        override fun getCount(): Int = items.size

        override fun getViewAt(position: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_task_row)
            val task = items.getOrNull(position) ?: return views
            val prefix = if (task.important) "! " else ""
            views.setTextViewText(R.id.row_title, prefix + task.title)
            views.setTextColor(R.id.row_title, if (task.overdue) style.warn else style.ink)
            views.setInt(R.id.row_box, "setBackgroundColor", style.ink)
            views.setInt(R.id.row_box_fill, "setBackgroundColor", style.paper)
            views.setInt(R.id.row_rule, "setBackgroundColor", style.muted)
            // Garis hanya di antara baris, seperti pemisah ListView biasa.
            views.setViewVisibility(
                R.id.row_rule,
                if (position == items.lastIndex) View.GONE else View.VISIBLE,
            )
            views.setContentDescription(R.id.row_check, "Selesaikan ${task.title}")
            // Hanya kotak centang yang bisa diketuk, agar tidak selesai tak sengaja.
            views.setOnClickFillInIntent(
                R.id.row_check,
                Intent().putExtra(TaskIntents.EXTRA_TASK_ID, task.id),
            )
            return views
        }

        override fun getLoadingView(): RemoteViews? = null

        override fun getViewTypeCount(): Int = 1

        override fun getItemId(position: Int): Long =
            items.getOrNull(position)?.id?.hashCode()?.toLong() ?: position.toLong()

        override fun hasStableIds(): Boolean = true
    }

    private companion object {
        const val MAX_ROWS = 50
    }
}
