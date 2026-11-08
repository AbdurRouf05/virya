package com.abdurrouf.virya.tasks

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

/**
 * Penyimpanan sisi native untuk widget & notifikasi.
 *
 * Native tidak pernah menulis ke SQLite: perubahan masuk ke antrean (inbox)
 * yang diterapkan Dart saat aplikasi aktif. Snapshot berisi tugas terbuka
 * terakhir dari Dart, dan [visible] menggabungkannya dengan antrean supaya
 * widget langsung benar walau aplikasi tidak berjalan.
 */
object TaskStore {
    data class WidgetTask(
        val id: String,
        val title: String,
        val overdue: Boolean,
        val important: Boolean,
        val pinned: Boolean,
    )

    private const val PREFS = "virya_tasks"
    private const val KEY_SNAPSHOT = "snapshot"
    private const val KEY_INBOX = "inbox"
    private const val KEY_QUICK = "quick_capture"
    private const val MAX_TITLE = 200

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun today(): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

    private fun parseArray(raw: String?): JSONArray =
        try {
            JSONArray(raw ?: "[]")
        } catch (_: JSONException) {
            JSONArray()
        }

    private fun objects(array: JSONArray): List<JSONObject> =
        (0 until array.length()).mapNotNull { array.optJSONObject(it) }

    private fun dayOf(o: JSONObject): String? =
        if (o.isNull("day")) null else o.optString("day")

    private fun enqueue(context: Context, op: JSONObject) {
        val p = prefs(context)
        val inbox = parseArray(p.getString(KEY_INBOX, null)).put(op)
        p.edit().putString(KEY_INBOX, inbox.toString()).commit()
    }

    /** Antrekan tugas baru. Mengembalikan judul tersimpan, atau null bila kosong. */
    @Synchronized
    fun capture(context: Context, rawTitle: String?): String? {
        val title = rawTitle?.trim()?.take(MAX_TITLE)
        if (title.isNullOrEmpty()) return null
        enqueue(
            context,
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("type", "capture")
                .put("title", title)
                .put("day", today())
                .put("at", System.currentTimeMillis()),
        )
        return title
    }

    @Synchronized
    fun markDone(context: Context, taskId: String) {
        enqueue(
            context,
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("type", "done")
                .put("taskId", taskId)
                .put("at", System.currentTimeMillis()),
        )
    }

    @Synchronized
    fun peekInbox(context: Context): String =
        parseArray(prefs(context).getString(KEY_INBOX, null)).toString()

    @Synchronized
    fun ackInbox(context: Context, ids: Collection<String>) {
        val p = prefs(context)
        val remaining = JSONArray()
        objects(parseArray(p.getString(KEY_INBOX, null)))
            .filterNot { it.optString("id") in ids }
            .forEach { remaining.put(it) }
        p.edit().putString(KEY_INBOX, remaining.toString()).commit()
    }

    @Synchronized
    fun setSnapshot(context: Context, json: String) {
        prefs(context).edit().putString(KEY_SNAPSHOT, json).commit()
    }

    /** Tugas untuk hari ini: snapshot − selesai tertunda + tangkapan tertunda. */
    @Synchronized
    fun visible(context: Context): List<WidgetTask> {
        val p = prefs(context)
        val now = today()
        val inbox = objects(parseArray(p.getString(KEY_INBOX, null)))
        val doneIds = inbox
            .filter { it.optString("type") == "done" }
            .map { it.optString("taskId") }
            .toSet()
        val result = LinkedHashMap<String, WidgetTask>()

        for (o in objects(parseArray(p.getString(KEY_SNAPSHOT, null)))) {
            val id = o.optString("id")
            val day = dayOf(o)
            val pinned = o.optBoolean("pinned")
            if (id.isEmpty() || id in doneIds) continue
            if (!pinned && (day == null || day > now)) continue
            result[id] = WidgetTask(
                id = id,
                title = o.optString("title"),
                overdue = day != null && day < now,
                important = o.optBoolean("important"),
                pinned = pinned,
            )
        }
        for (o in inbox.filter { it.optString("type") == "capture" }) {
            val id = o.optString("id")
            val day = dayOf(o)
            if (id.isEmpty() || id in doneIds || id in result) continue
            result[id] = WidgetTask(
                id = id,
                title = o.optString("title"),
                overdue = day != null && day < now,
                important = false,
                pinned = false,
            )
        }
        return result.values.toList()
    }

    fun isQuickCaptureOn(context: Context): Boolean =
        prefs(context).getBoolean(KEY_QUICK, false)

    fun setQuickCaptureOn(context: Context, on: Boolean) {
        prefs(context).edit().putBoolean(KEY_QUICK, on).commit()
    }
}
