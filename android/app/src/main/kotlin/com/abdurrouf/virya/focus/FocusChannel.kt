package com.abdurrouf.virya.focus

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.Executors

/** Jembatan Dart ⇄ Android untuk modul fokus (`virya/focus`). */
class FocusChannel(
    context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val appContext = context.applicationContext
    private val channel = MethodChannel(messenger, CHANNEL)
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPermissions" -> result.success(
                hashMapOf(
                    "usageAccess" to FocusUsage.hasUsageAccess(appContext),
                    "accessibility" to isAccessibilityEnabled(),
                ),
            )
            "openUsageSettings" -> {
                openSettings(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                result.success(null)
            }
            "openAccessibilitySettings" -> {
                openSettings(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                result.success(null)
            }
            "openAppSettings" -> {
                openAppSettings()
                result.success(null)
            }
            "installedApps" -> inBackground(result) { installedApps() }
            "pushLimits" -> {
                FocusStore.setLimits(appContext, call.arguments as? String ?: "[]")
                result.success(null)
            }
            "readUsage" -> {
                val days = ((call.arguments as? Int) ?: 1).coerceIn(1, MAX_DAYS)
                inBackground(result) { readUsage(days) }
            }
            else -> result.notImplemented()
        }
    }

    private fun inBackground(result: MethodChannel.Result, work: () -> String) {
        executor.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: RuntimeException) {
                main.post { result.error("focus_failed", e.message, null) }
            }
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val raw = Settings.Secure.getString(
            appContext.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val service = ComponentName(appContext, FocusAccessibilityService::class.java)
        return raw.split(':').any { ComponentName.unflattenFromString(it) == service }
    }

    private fun openSettings(action: String) {
        try {
            appContext.startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (_: ActivityNotFoundException) {
            appContext.startActivity(
                Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }

    private fun openAppSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", appContext.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            appContext.startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            openSettings(Settings.ACTION_SETTINGS)
        }
    }

    private fun installedApps(): String {
        val pm = appContext.packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val apps = pm.queryIntentActivities(launcher, 0)
            .distinctBy { it.activityInfo.packageName }
            .filter { it.activityInfo.packageName != appContext.packageName }
            .map { it.activityInfo.packageName to it.loadLabel(pm).toString() }
            .sortedWith(compareBy(String.CASE_INSENSITIVE_ORDER) { it.second })
        val out = JSONArray()
        for ((packageName, label) in apps) {
            out.put(JSONObject().put("packageName", packageName).put("label", label))
        }
        return out.toString()
    }

    private fun readUsage(days: Int): String {
        val packages = FocusStore.limitedPackages(appContext)
        val rows = JSONArray()
        val todayKey = FocusStore.dayKey()
        for ((day, perPackage) in FocusUsage.readDays(appContext, packages, days)) {
            for ((packageName, millis) in perPackage) {
                val minutes = millis / MILLIS_PER_MINUTE
                if (minutes <= 0) continue
                rows.put(
                    JSONObject()
                        .put("day", day)
                        .put("packageName", packageName)
                        .put("minutes", minutes),
                )
                if (day == todayKey) {
                    val limit = FocusStore.limitFor(appContext, packageName)
                    if (limit != null && limit.enabled) {
                        val allowedMs = (limit.dailyMinutes + FocusStore.bonusMinutes(appContext, packageName)) * MILLIS_PER_MINUTE
                        if (millis >= allowedMs) {
                            FocusNotification.notifyLimitReached(
                                appContext,
                                packageName,
                                limit.label,
                                limit.dailyMinutes,
                            )
                        }
                    }
                }
            }
        }
        return JSONObject()
            .put("rows", rows)
            .put("bonus", FocusStore.bonusJson(appContext))
            .toString()
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    private companion object {
        const val CHANNEL = "virya/focus"
        const val MAX_DAYS = 31
        const val MILLIS_PER_MINUTE = 60_000L
    }
}
