package com.abdurrouf.virya.focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.PowerManager
import android.os.SystemClock
import com.abdurrouf.virya.MainActivity
import com.abdurrouf.virya.R

/**
 * Penjaga Fokus tanpa Aksesibilitas (Mode Ramah Bank). Membaca aplikasi yang
 * sedang di depan dari log Akses Penggunaan setiap beberapa detik, lalu
 * menampilkan layar "Waktu habis" atau penghalang rutinitas di atasnya. Butuh izin "Tampil di atas
 * aplikasi lain" agar boleh membuka layar dari latar belakang.
 */
class FocusGuardService : Service() {
    private val thread = HandlerThread("focus-guard-service")
    private lateinit var worker: Handler
    private val tickRunnable = Runnable { tick() }

    private var current: String? = null
    private var currentClass: String? = null
    private var lastEventAt = 0L

    private var checkedPackage: String? = null
    private var nextCheckAt = 0L
    private var lastBlockAt = 0L

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        thread.start()
        worker = Handler(thread.looper)
        lastEventAt = System.currentTimeMillis() - SEED_WINDOW_MS
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startInForeground()
        worker.removeCallbacks(tickRunnable)
        // Batas bisa berubah; hitung ulang dari awal.
        worker.post {
            nextCheckAt = 0L
            tick()
        }
        return START_STICKY
    }

    private fun startInForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun tick() {
        worker.removeCallbacks(tickRunnable)
        if (!shouldRun(this)) {
            stopSelf()
            return
        }
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!power.isInteractive || FocusGuard.isAccessibilityEnabled(this)) {
            // Layar mati, atau Aksesibilitas sudah menjaga: cukup cek sesekali.
            checkedPackage = null
            worker.postDelayed(tickRunnable, IDLE_MS)
            return
        }
        readForeground()
        check()
        worker.postDelayed(tickRunnable, TICK_MS)
    }

    /** Memperbarui [current] dari kejadian sejak pembacaan terakhir. */
    private fun readForeground() {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return
        val now = System.currentTimeMillis()
        val events = manager.queryEvents(lastEventAt - OVERLAP_MS, now) ?: return
        val event = UsageEvents.Event()
        var newest = lastEventAt
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.timeStamp <= lastEventAt) continue
            newest = maxOf(newest, event.timeStamp)
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    current = event.packageName
                    currentClass = event.className
                }
                UsageEvents.Event.ACTIVITY_PAUSED, ACTIVITY_STOPPED ->
                    if (event.packageName == current && event.className == currentClass) {
                        current = null
                    }
            }
        }
        lastEventAt = newest
    }

    private fun check() {
        val pkg = current
        val now = SystemClock.elapsedRealtime()
        if (pkg != checkedPackage) {
            checkedPackage = pkg
            nextCheckAt = 0L
            if (pkg != null && pkg != packageName && FocusGuard.gateIfNeeded(this, pkg)) return
        }
        if (pkg == null || pkg == packageName || now < nextCheckAt) return
        val remaining = FocusGuard.remainingMs(this, pkg)
        if (remaining == null) {
            nextCheckAt = Long.MAX_VALUE
            return
        }
        when {
            remaining > FocusGuard.WARN_BEFORE_MS ->
                nextCheckAt = now + remaining - FocusGuard.WARN_BEFORE_MS
            remaining > 0 -> {
                FocusGuard.warnIfClose(this, pkg, remaining)
                nextCheckAt = now + remaining
            }
            now - lastBlockAt < BLOCK_COOLDOWN_MS -> Unit
            else -> {
                lastBlockAt = now
                FocusGuard.showBlock(this, pkg)
            }
        }
    }

    private fun buildNotification(): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.focus_guard_channel),
                    NotificationManager.IMPORTANCE_MIN,
                ).apply { setShowBadge(false) },
            )
        }
        val open = PendingIntent.getActivity(
            this,
            NOTIFICATION_ID,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val count = FocusStore.limitedPackages(this).count { FocusStore.limitFor(this, it)?.enabled == true }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this).setPriority(Notification.PRIORITY_MIN)
        }
        return builder
            .setSmallIcon(R.drawable.ic_task_quick)
            .setContentTitle(getString(R.string.focus_guard_title))
            .setContentText(getString(R.string.focus_guard_text, count))
            .setOngoing(true)
            .setContentIntent(open)
            .build()
    }

    override fun onDestroy() {
        worker.removeCallbacksAndMessages(null)
        thread.quitSafely()
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_ID = "focus_guard"
        private const val NOTIFICATION_ID = 4107
        private const val ACTIVITY_STOPPED = 23
        private const val TICK_MS = 3_000L
        private const val IDLE_MS = 15_000L
        private const val OVERLAP_MS = 2_000L
        private const val SEED_WINDOW_MS = 10 * 60_000L
        private const val BLOCK_COOLDOWN_MS = 4_000L

        private fun shouldRun(context: Context): Boolean =
            FocusUsage.hasUsageAccess(context) &&
                FocusGuard.canDrawOverlays(context) &&
                (
                    FocusGate.hasApps(context) ||
                        FocusStore.limitedPackages(context).any { FocusStore.limitFor(context, it)?.enabled == true }
                    )

        /** Menyalakan atau mematikan penjaga sesuai izin dan batas yang ada. */
        fun sync(context: Context) {
            val app = context.applicationContext
            val intent = Intent(app, FocusGuardService::class.java)
            if (shouldRun(app) && !FocusGuard.isAccessibilityEnabled(app)) {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        app.startForegroundService(intent)
                    } else {
                        app.startService(intent)
                    }
                } catch (_: RuntimeException) {
                    // Android menolak memulai dari latar; dicoba lagi saat Virya dibuka.
                }
            } else {
                app.stopService(intent)
            }
        }
    }
}
