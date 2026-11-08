package com.abdurrouf.virya.tasks

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Jembatan Dart ⇄ Android untuk modul tugas (`virya/tasks`). */
class TaskChannel(
    context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val appContext = context.applicationContext
    private val channel = MethodChannel(messenger, CHANNEL)
    private var pendingAction: String? = null

    init {
        channel.setMethodCallHandler(this)
        active = this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pushSnapshot" -> {
                TaskStore.setSnapshot(appContext, call.arguments as? String ?: "[]")
                refreshTaskSurfaces(appContext)
                result.success(null)
            }
            "peekInbox" -> result.success(TaskStore.peekInbox(appContext))
            "ackInbox" -> {
                val ids = (call.arguments as? List<*>).orEmpty().filterIsInstance<String>()
                TaskStore.ackInbox(appContext, ids)
                result.success(null)
            }
            "takeLaunchAction" -> {
                result.success(pendingAction)
                pendingAction = null
            }
            "isQuickCaptureOn" -> result.success(TaskStore.isQuickCaptureOn(appContext))
            "setQuickCapture" -> {
                val on = call.arguments as? Boolean ?: false
                TaskStore.setQuickCaptureOn(appContext, on)
                if (on) QuickCaptureNotification.show(appContext)
                else QuickCaptureNotification.cancel(appContext)
                result.success(null)
            }
            "canPinWidget" -> result.success(canPinWidget())
            "requestPinWidget" -> {
                if (canPinWidget() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    AppWidgetManager.getInstance(appContext).requestPinAppWidget(
                        ComponentName(appContext, TaskWidgetProvider::class.java),
                        null,
                        null,
                    )
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun canPinWidget(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            AppWidgetManager.getInstance(appContext).isRequestPinAppWidgetSupported

    /** Tangkap intent catat cepat; aksi di-reset agar tidak terpicu dua kali. */
    fun handleIntent(intent: Intent?) {
        if (intent?.action != TaskIntents.ACTION_QUICK_TASK) return
        val fromHistory =
            intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        intent.action = Intent.ACTION_MAIN
        if (fromHistory) return
        pendingAction = ACTION_NAME_QUICK_TASK
        channel.invokeMethod("launchAction", null)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        if (active === this) active = null
    }

    private fun pingInbox() {
        channel.invokeMethod("inboxChanged", null)
    }

    companion object {
        private const val CHANNEL = "virya/tasks"
        private const val ACTION_NAME_QUICK_TASK = "quick_task"
        private var active: TaskChannel? = null

        /** Beri tahu Dart (bila berjalan) bahwa antrean berubah. */
        fun notifyInboxChanged() {
            active?.pingInbox()
        }
    }
}

/** Segarkan widget dan notifikasi setelah data berubah. */
fun refreshTaskSurfaces(context: Context, saved: String? = null) {
    TaskWidgetProvider.refresh(context)
    if (TaskStore.isQuickCaptureOn(context)) {
        QuickCaptureNotification.show(context, saved)
    }
}
