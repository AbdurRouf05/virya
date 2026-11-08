package com.abdurrouf.virya

import android.content.Context
import android.content.SharedPreferences
import com.abdurrouf.virya.tasks.TaskWidgetProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Warna style aktif untuk permukaan yang digambar tanpa Flutter. Dart yang
 * menulisnya; sebelum pernah ditulis, nilainya warna Field Notes di resources.
 */
object NativeStyle {
    data class Colors(
        val paper: Int,
        val ink: Int,
        val warn: Int,
        val muted: Int,
        val dark: Boolean,
    )

    private const val PREFS = "virya_style"
    private const val KEY_PAPER = "paper"
    private const val KEY_INK = "ink"
    private const val KEY_WARN = "warn"
    private const val KEY_MUTED = "muted"
    private const val KEY_DARK = "dark"

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun colors(context: Context): Colors {
        val p = prefs(context)
        return Colors(
            paper = p.getInt(KEY_PAPER, context.getColor(R.color.task_paper)),
            ink = p.getInt(KEY_INK, context.getColor(R.color.task_ink)),
            warn = p.getInt(KEY_WARN, context.getColor(R.color.task_warn)),
            muted = p.getInt(KEY_MUTED, context.getColor(R.color.task_muted)),
            dark = p.getBoolean(KEY_DARK, false),
        )
    }

    fun save(context: Context, colors: Colors) {
        prefs(context).edit()
            .putInt(KEY_PAPER, colors.paper)
            .putInt(KEY_INK, colors.ink)
            .putInt(KEY_WARN, colors.warn)
            .putInt(KEY_MUTED, colors.muted)
            .putBoolean(KEY_DARK, colors.dark)
            .apply()
    }
}

/** Jembatan Dart ke Android untuk warna style (`virya/style`). */
class StyleChannel(
    context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val appContext = context.applicationContext
    private val channel = MethodChannel(messenger, CHANNEL)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "apply") {
            result.notImplemented()
            return
        }
        // ARGB 0xFF... melebihi Int di Dart sehingga tiba sebagai Long.
        fun color(key: String): Int? = (call.argument<Any>(key) as? Number)?.toInt()
        val paper = color("paper")
        val ink = color("ink")
        val warn = color("warn")
        val muted = color("muted")
        val dark = call.argument<Boolean>("dark")
        if (paper == null || ink == null || warn == null || muted == null || dark == null) {
            result.error("bad_args", "Warna style tidak lengkap", null)
            return
        }
        NativeStyle.save(appContext, NativeStyle.Colors(paper, ink, warn, muted, dark))
        TaskWidgetProvider.refresh(appContext)
        result.success(null)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    private companion object {
        const val CHANNEL = "virya/style"
    }
}
