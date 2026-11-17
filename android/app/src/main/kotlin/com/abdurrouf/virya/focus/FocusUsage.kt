package com.abdurrouf.virya.focus

import android.Manifest
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import java.util.Calendar

/**
 * Menghitung waktu layar per hari lokal dari log kejadian Android.
 * `queryUsageStats` tidak dipakai karena ember hariannya tidak jatuh tepat
 * di tengah malam lokal.
 */
object FocusUsage {
    private const val ACTIVITY_RESUMED = 1
    private const val ACTIVITY_PAUSED = 2
    private const val SCREEN_NON_INTERACTIVE = 16
    private const val ACTIVITY_STOPPED = 23
    private const val DEVICE_SHUTDOWN = 26
    private const val DEVICE_STARTUP = 27

    /** Agar sesi yang sudah berjalan saat tengah malam tetap terhitung. */
    private const val LOOKBACK_MS = 6 * 60 * 60 * 1000L

    private class Session(val start: Long, var className: String?)

    @Suppress("DEPRECATION")
    fun hasUsageAccess(context: Context): Boolean {
        val ops = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ops.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        } else {
            ops.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        if (mode == AppOpsManager.MODE_DEFAULT) {
            return context.checkCallingOrSelfPermission(Manifest.permission.PACKAGE_USAGE_STATS) ==
                PackageManager.PERMISSION_GRANTED
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun usedTodayMs(context: Context, packageName: String): Long =
        readDays(context, setOf(packageName), 1)[FocusStore.dayKey()]?.get(packageName) ?: 0L

    /** Hari (`YYYY-MM-DD`) → paket → milidetik di latar depan. */
    fun readDays(
        context: Context,
        packages: Set<String>,
        days: Int,
    ): Map<String, Map<String, Long>> {
        if (packages.isEmpty() || !hasUsageAccess(context)) return emptyMap()
        val manager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return emptyMap()
        val now = System.currentTimeMillis()
        val bounds = dayBounds(now, days)
        val totals = LinkedHashMap<String, MutableMap<String, Long>>()
        val open = HashMap<String, Session>()
        val events = manager.queryEvents(bounds.first() - LOOKBACK_MS, now) ?: return emptyMap()

        fun close(packageName: String, at: Long) {
            val session = open.remove(packageName) ?: return
            addSplit(totals, bounds, packageName, session.start, at)
        }

        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val packageName = event.packageName
            val at = event.timeStamp
            when (event.eventType) {
                ACTIVITY_RESUMED -> {
                    open.keys.filter { it != packageName }.forEach { close(it, at) }
                    if (packageName in packages) {
                        val session = open[packageName]
                        if (session == null) {
                            open[packageName] = Session(at, event.className)
                        } else {
                            session.className = event.className
                        }
                    }
                }
                // Saat pindah layar dalam satu aplikasi, aktivitas lama berhenti
                // setelah aktivitas baru tampil. Hanya aktivitas yang sedang
                // tampil yang boleh menutup sesi.
                ACTIVITY_PAUSED, ACTIVITY_STOPPED ->
                    if (open[packageName]?.className == event.className) close(packageName, at)
                SCREEN_NON_INTERACTIVE, DEVICE_SHUTDOWN, DEVICE_STARTUP ->
                    open.keys.toList().forEach { close(it, at) }
            }
        }
        open.keys.toList().forEach { close(it, now) }
        return totals
    }

    /** Tengah malam lokal dari hari terlama sampai besok, urut naik. */
    private fun dayBounds(now: Long, days: Int): List<Long> {
        val cal = Calendar.getInstance().apply {
            timeInMillis = now
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.DAY_OF_MONTH, -(days - 1))
        }
        return List(days + 1) { index ->
            if (index > 0) cal.add(Calendar.DAY_OF_MONTH, 1)
            cal.timeInMillis
        }
    }

    private fun addSplit(
        totals: MutableMap<String, MutableMap<String, Long>>,
        bounds: List<Long>,
        packageName: String,
        start: Long,
        end: Long,
    ) {
        for (i in 0 until bounds.size - 1) {
            val from = maxOf(start, bounds[i])
            val to = minOf(end, bounds[i + 1])
            if (to <= from) continue
            val perPackage = totals.getOrPut(FocusStore.dayKey(bounds[i])) { HashMap() }
            perPackage[packageName] = (perPackage[packageName] ?: 0L) + (to - from)
        }
    }
}
