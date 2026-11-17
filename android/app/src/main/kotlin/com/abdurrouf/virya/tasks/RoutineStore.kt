package com.abdurrouf.virya.tasks

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Rutinitas harian dari Dart, untuk pengingat, penghalang aplikasi, dan
 * ringkasan notifikasi. `doneDay` memungkinkan native memilah sendiri saat
 * hari berganti tanpa aplikasi berjalan. Centang dari luar aplikasi masuk
 * antrean [TaskStore] dan langsung dianggap selesai di sini.
 */
object RoutineStore {
    data class Routine(
        val id: String,
        val title: String,
        /** Menit sejak tengah malam lokal, null = tanpa pengingat. */
        val remind: Int?,
        val doneDay: String?,
    )

    private const val PREFS = "virya_tasks"
    private const val KEY_ROUTINES = "routines"
    private const val KEY_STATE = "routine_state"

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun dayKey(millis: Long = System.currentTimeMillis()): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(millis))

    private fun parseArray(raw: String?): JSONArray =
        try {
            JSONArray(raw ?: "[]")
        } catch (_: JSONException) {
            JSONArray()
        }

    private fun parseObject(raw: String?): JSONObject =
        try {
            JSONObject(raw ?: "{}")
        } catch (_: JSONException) {
            JSONObject()
        }

    @Synchronized
    fun setRoutines(context: Context, json: String) {
        prefs(context).edit().putString(KEY_ROUTINES, json).commit()
    }

    @Synchronized
    fun all(context: Context): List<Routine> {
        val array = parseArray(prefs(context).getString(KEY_ROUTINES, null))
        return (0 until array.length()).mapNotNull { i ->
            val o = array.optJSONObject(i) ?: return@mapNotNull null
            val id = o.optString("id")
            if (id.isEmpty()) return@mapNotNull null
            Routine(
                id = id,
                title = o.optString("title"),
                remind = if (o.isNull("remind")) null else o.optInt("remind"),
                doneDay = if (o.isNull("doneDay")) null else o.optString("doneDay"),
            )
        }
    }

    /** Rutinitas yang belum dicentang hari ini (termasuk centang tertunda). */
    fun pending(context: Context): List<Routine> {
        val today = dayKey()
        val doneNow = TaskStore.doneToday(context)
        return all(context).filter { it.doneDay != today && it.id !in doneNow }
    }

    // --- Status pengingat per rutinitas: kapan terakhir diingatkan & tunda. ---

    private fun state(context: Context): JSONObject =
        parseObject(prefs(context).getString(KEY_STATE, null))

    private fun entry(context: Context, id: String): JSONObject =
        state(context).optJSONObject(id) ?: JSONObject()

    @Synchronized
    private fun putEntry(context: Context, id: String, change: (JSONObject) -> Unit) {
        val all = state(context)
        val e = all.optJSONObject(id) ?: JSONObject()
        change(e)
        all.put(id, e)
        // Buang status rutinitas yang sudah dihapus.
        val ids = all(context).map { it.id }.toSet()
        all.keys().asSequence().toList().filter { it !in ids && it != id }.forEach { all.remove(it) }
        prefs(context).edit().putString(KEY_STATE, all.toString()).commit()
    }

    fun lastNotified(context: Context, id: String): Long = entry(context, id).optLong("notified", 0L)

    fun snoozeUntil(context: Context, id: String): Long = entry(context, id).optLong("snooze", 0L)

    fun markNotified(context: Context, id: String, at: Long) =
        putEntry(context, id) {
            it.put("notified", at)
            it.remove("snooze")
        }

    fun snooze(context: Context, id: String, until: Long) =
        putEntry(context, id) { it.put("snooze", until) }
}
