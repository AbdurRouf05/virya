package com.abdurrouf.virya.focus

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Salinan batas aplikasi dari Dart dan tambahan menit hari ini. Sumber data
 * batas tetap SQLite; native hanya menyimpan apa yang perlu untuk menegakkannya.
 */
object FocusStore {
    data class Limit(
        val packageName: String,
        val label: String,
        val dailyMinutes: Int,
        val enabled: Boolean,
    )

    const val BONUS_MINUTES = 5

    private const val PREFS = "virya_focus"
    private const val KEY_LIMITS = "limits"
    private const val KEY_BONUS_DAY = "bonus_day"
    private const val KEY_BONUS_PACKAGES = "bonus_packages"

    private var cachedRaw: String? = null
    private var cachedLimits: Map<String, Limit> = emptyMap()

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun dayKey(millis: Long = System.currentTimeMillis()): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(millis))

    @Synchronized
    fun setLimits(context: Context, json: String) {
        prefs(context).edit().putString(KEY_LIMITS, json).commit()
    }

    @Synchronized
    private fun limits(context: Context): Map<String, Limit> {
        val raw = prefs(context).getString(KEY_LIMITS, null) ?: "[]"
        if (raw != cachedRaw) {
            cachedLimits = parseLimits(raw)
            cachedRaw = raw
        }
        return cachedLimits
    }

    private fun parseLimits(raw: String): Map<String, Limit> {
        val array = try {
            JSONArray(raw)
        } catch (_: JSONException) {
            JSONArray()
        }
        val out = LinkedHashMap<String, Limit>()
        for (i in 0 until array.length()) {
            val o = array.optJSONObject(i) ?: continue
            val packageName = o.optString("packageName")
            if (packageName.isEmpty()) continue
            out[packageName] = Limit(
                packageName = packageName,
                label = o.optString("label", packageName),
                dailyMinutes = o.optInt("dailyMinutes"),
                enabled = o.optBoolean("enabled", true),
            )
        }
        return out
    }

    fun limitFor(context: Context, packageName: String): Limit? =
        limits(context)[packageName]

    fun limitedPackages(context: Context): Set<String> = limits(context).keys

    /** Paket yang sudah mengambil tambahan menit hari ini. */
    private fun bonusPackages(p: SharedPreferences): Set<String> =
        if (p.getString(KEY_BONUS_DAY, null) == dayKey()) {
            p.getStringSet(KEY_BONUS_PACKAGES, null).orEmpty()
        } else {
            emptySet()
        }

    @Synchronized
    fun bonusMinutes(context: Context, packageName: String): Int =
        if (packageName in bonusPackages(prefs(context))) BONUS_MINUTES else 0

    @Synchronized
    fun bonusJson(context: Context): JSONObject {
        val out = JSONObject()
        bonusPackages(prefs(context)).forEach { out.put(it, BONUS_MINUTES) }
        return out
    }

    /** Beri tambahan satu kali per aplikasi per hari. False bila sudah diambil. */
    @Synchronized
    fun grantBonus(context: Context, packageName: String): Boolean {
        val p = prefs(context)
        val taken = bonusPackages(p)
        if (packageName in taken) return false
        p.edit()
            .putString(KEY_BONUS_DAY, dayKey())
            .putStringSet(KEY_BONUS_PACKAGES, taken + packageName)
            .commit()
        return true
    }
}
