package com.abdurrouf.virya

import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * MethodChannel `virya/video_encoder`. All encoder work runs on a dedicated
 * HandlerThread; results are posted back on the main thread.
 */
class VideoEncoderChannel(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "virya/video_encoder")
    private val thread = HandlerThread("ViryaVideoEncoder").apply { start() }
    private val worker = Handler(thread.looper)
    private val main = Handler(Looper.getMainLooper())

    // Accessed only on the worker thread.
    private val sessions = HashMap<Int, Mp4Encoder>()
    private var nextId = 1

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start", "addFrameRgba", "addFrameImage", "finish", "cancel" ->
                worker.post { handle(call, result) }
            else -> result.notImplemented()
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> {
                    val path = call.argument<String>("outputPath")
                        ?: throw IllegalArgumentException("outputPath wajib")
                    val w = call.argument<Int>("width") ?: throw IllegalArgumentException("width wajib")
                    val h = call.argument<Int>("height") ?: throw IllegalArgumentException("height wajib")
                    val fps = call.argument<Int>("fps") ?: 30
                    val bitrate = call.argument<Int>("bitrate") ?: 8_000_000
                    val enc = Mp4Encoder(path, w, h, fps, bitrate)
                    try {
                        enc.start()
                    } catch (e: Throwable) {
                        enc.cancel()
                        throw e
                    }
                    val id = nextId++
                    sessions[id] = enc
                    ok(result, mapOf("id" to id, "width" to enc.width, "height" to enc.height))
                }
                "addFrameRgba" -> {
                    val enc = session(call)
                    val bytes = call.argument<ByteArray>("bytes")
                        ?: throw IllegalArgumentException("bytes wajib")
                    val w = call.argument<Int>("width") ?: enc.width
                    val h = call.argument<Int>("height") ?: enc.height
                    try {
                        enc.addFrameRgba(bytes, w, h)
                    } catch (e: Exception) {
                        drop(call); throw e
                    }
                    ok(result, null)
                }
                "addFrameImage" -> {
                    val enc = session(call)
                    val bytes = call.argument<ByteArray>("bytes")
                        ?: throw IllegalArgumentException("bytes wajib")
                    val w = call.argument<Int>("width") ?: enc.width
                    val h = call.argument<Int>("height") ?: enc.height
                    try {
                        enc.addFrameImage(bytes, w, h)
                    } catch (e: Exception) {
                        drop(call); throw e
                    }
                    ok(result, null)
                }
                "finish" -> {
                    val id = call.argument<Int>("id") ?: -1
                    val enc = sessions.remove(id) ?: throw IllegalStateException("Sesi encoder tidak ada")
                    try {
                        ok(result, enc.finish())
                    } catch (e: Exception) {
                        enc.cancel(); throw e
                    }
                }
                "cancel" -> {
                    val id = call.argument<Int>("id") ?: -1
                    sessions.remove(id)?.cancel()
                    ok(result, null)
                }
            }
        } catch (e: Throwable) {
            main.post { result.error("encoder_error", e.message ?: e.javaClass.simpleName, null) }
        }
    }

    private fun session(call: MethodCall): Mp4Encoder {
        val id = call.argument<Int>("id") ?: -1
        return sessions[id] ?: throw IllegalStateException("Sesi encoder tidak ada")
    }

    private fun drop(call: MethodCall) {
        val id = call.argument<Int>("id") ?: -1
        sessions.remove(id)?.cancel()
    }

    private fun ok(result: MethodChannel.Result, value: Any?) {
        main.post { result.success(value) }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        worker.post {
            sessions.values.forEach { it.cancel() }
            sessions.clear()
            thread.quitSafely()
        }
    }
}
