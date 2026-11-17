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
 * Salinan batas aplikasi dari Dart dan berapa kali tiap aplikasi dibuka lagi hari ini. Sumber data
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
    private const val KEY_UNLOCKS = "unlocks"
    private val WAIT_SECONDS = intArrayOf(10, 20, 40, 60)

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

    /**
     * Berapa kali tiap paket dibuka lagi setelah waktunya habis, hari ini.
     * Format lama (set paket, maks sekali) dibaca sebagai 1 kali.
     */
    private fun unlocks(p: SharedPreferences): Map<String, Int> {
        if (p.getString(KEY_BONUS_DAY, null) != dayKey()) return emptyMap()
        val out = HashMap<String, Int>()
        p.getStringSet(KEY_BONUS_PACKAGES, null).orEmpty().forEach { out[it] = 1 }
        val raw = p.getString(KEY_UNLOCKS, null) ?: return out
        try {
            val o = JSONObject(raw)
            o.keys().forEach { out[it] = o.optInt(it) }
        } catch (_: JSONException) {
        }
        return out
    }

    @Synchronized
    fun unlockCount(context: Context, packageName: String): Int =
        unlocks(prefs(context))[packageName] ?: 0

    /** Menit tambahan hari ini: [BONUS_MINUTES] untuk tiap kali dibuka lagi. */
    @Synchronized
    fun bonusMinutes(context: Context, packageName: String): Int =
        unlockCount(context, packageName) * BONUS_MINUTES

    @Synchronized
    fun bonusJson(context: Context): JSONObject {
        val out = JSONObject()
        unlocks(prefs(context)).forEach { (pkg, n) -> out.put(pkg, n * BONUS_MINUTES) }
        return out
    }

    /** Detik tunggu sebelum tombol "Tetap buka" aktif. Makin sering, makin lama. */
    fun waitSeconds(unlockCount: Int): Int =
        WAIT_SECONDS[minOf(unlockCount, WAIT_SECONDS.lastIndex)]

    /** Catat satu kali buka lagi (+[BONUS_MINUTES] menit). Mengembalikan jumlah baru. */
    @Synchronized
    fun grantBonus(context: Context, packageName: String): Int {
        val p = prefs(context)
        val next = unlocks(p) + (packageName to (unlocks(p)[packageName] ?: 0) + 1)
        val json = JSONObject()
        next.forEach { (pkg, n) -> json.put(pkg, n) }
        p.edit()
            .putString(KEY_BONUS_DAY, dayKey())
            .remove(KEY_BONUS_PACKAGES)
            .putString(KEY_UNLOCKS, json.toString())
            .commit()
        return next.getValue(packageName)
    }
}
