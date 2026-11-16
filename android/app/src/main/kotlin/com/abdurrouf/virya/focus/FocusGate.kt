package com.abdurrouf.virya.focus

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.abdurrouf.virya.tasks.RoutineStore
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * Penghalang rutinitas: saat aplikasi pilihan dibuka dan masih ada rutinitas
 * hari ini yang belum dicentang, tampilkan daftarnya dulu. Paling sering sekali
 * per [COOLDOWN_MS] untuk tiap aplikasi.
 */
object FocusGate {
    private const val PREFS = "virya_gate"
    private const val KEY_APPS = "apps"
    private const val KEY_SHOWN = "shown"
    private const val COOLDOWN_MS = 30 * 60_000L

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun parseObject(raw: String?): JSONObject =
        try {
            JSONObject(raw ?: "{}")
        } catch (_: JSONException) {
            JSONObject()
        }

    /** JSON `[{packageName, label}]`, apa adanya dari Dart. */
    fun appsJson(context: Context): String = prefs(context).getString(KEY_APPS, null) ?: "[]"

    fun setAppsJson(context: Context, json: String) {
        prefs(context).edit().putString(KEY_APPS, json).commit()
    }

    /** packageName → label. */
    fun apps(context: Context): Map<String, String> {
        val array = try {
            JSONArray(appsJson(context))
        } catch (_: JSONException) {
            JSONArray()
        }
        return (0 until array.length()).mapNotNull { array.optJSONObject(it) }
            .filter { it.optString("packageName").isNotEmpty() }
            .associate { it.optString("packageName") to it.optString("label") }
    }

    fun hasApps(context: Context): Boolean = apps(context).isNotEmpty()

    /** Tampilkan penghalang bila perlu. True bila layar penghalang dibuka. */
    @Synchronized
    fun maybeShow(context: Context, packageName: String): Boolean {
        val label = apps(context)[packageName] ?: return false
        if (RoutineStore.pending(context).isEmpty()) return false
        val now = System.currentTimeMillis()
        val shown = parseObject(prefs(context).getString(KEY_SHOWN, null))
        if (now - shown.optLong(packageName, 0L) < COOLDOWN_MS) return false
        shown.put(packageName, now)
        prefs(context).edit().putString(KEY_SHOWN, shown.toString()).commit()
        context.startActivity(
            Intent(context, RoutineGateActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra(RoutineGateActivity.EXTRA_PACKAGE, packageName)
                .putExtra(RoutineGateActivity.EXTRA_LABEL, label),
        )
        return true
    }
}
