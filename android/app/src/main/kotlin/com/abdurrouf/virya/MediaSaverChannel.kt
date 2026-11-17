package com.abdurrouf.virya

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * MethodChannel `virya/media_saver` untuk menyimpan gambar dan video langsung ke
 * penyimpanan publik perangkat (MediaStore: Pictures/Virya dan Movies/Virya) agar
 * dapat langsung muncul di Galeri HP, Google Photos, dan pengelola berkas.
 */
class MediaSaverChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "virya/media_saver")
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "saveImageToGallery" -> {
                val path = call.argument<String>("path")
                val name = call.argument<String>("name")
                if (path == null || name == null) {
                    result.error("INVALID_ARGS", "Path or name missing", null)
                    return
                }
                Thread {
                    try {
                        val savedPath = saveImage(File(path), name)
                        mainHandler.post { result.success(savedPath) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("SAVE_FAILED", e.message, null) }
                    }
                }.start()
            }
            "saveVideoToGallery" -> {
                val path = call.argument<String>("path")
                val name = call.argument<String>("name")
                if (path == null || name == null) {
                    result.error("INVALID_ARGS", "Path or name missing", null)
                    return
                }
                Thread {
                    try {
                        val savedPath = saveVideo(File(path), name)
                        mainHandler.post { result.success(savedPath) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("SAVE_FAILED", e.message, null) }
                    }
                }.start()
            }
            else -> result.notImplemented()
        }
    }

    private fun saveImage(source: File, name: String): String {
        val filename = if (name.endsWith(".png", ignoreCase = true) || name.endsWith(".jpg", ignoreCase = true)) name else "$name.png"
        val mimeType = if (filename.endsWith(".jpg", ignoreCase = true) || filename.endsWith(".jpeg", ignoreCase = true)) "image/jpeg" else "image/png"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/Virya")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val resolver = context.contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Gagal membuat entri galeri foto")

            resolver.openOutputStream(uri)?.use { out ->
                FileInputStream(source).use { input -> input.copyTo(out) }
            } ?: throw IllegalStateException("Gagal menyalin foto ke galeri")

            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return "Pictures/Virya/$filename"
        } else {
            val dir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Virya")
            if (!dir.exists()) dir.mkdirs()
            val dest = File(dir, filename)
            FileInputStream(source).use { input ->
                FileOutputStream(dest).use { out -> input.copyTo(out) }
            }
            MediaScannerConnection.scanFile(context, arrayOf(dest.absolutePath), arrayOf(mimeType), null)
            return "Pictures/Virya/$filename"
        }
    }

    private fun saveVideo(source: File, name: String): String {
        val filename = if (name.endsWith(".mp4", ignoreCase = true)) name else "$name.mp4"
        val mimeType = "video/mp4"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, filename)
                put(MediaStore.Video.Media.MIME_TYPE, mimeType)
                put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/Virya")
                put(MediaStore.Video.Media.IS_PENDING, 1)
            }
            val resolver = context.contentResolver
            val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Gagal membuat entri galeri video")

            resolver.openOutputStream(uri)?.use { out ->
                FileInputStream(source).use { input -> input.copyTo(out) }
            } ?: throw IllegalStateException("Gagal menyalin video ke galeri")

            values.clear()
            values.put(MediaStore.Video.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return "Movies/Virya/$filename"
        } else {
            val dir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES), "Virya")
            if (!dir.exists()) dir.mkdirs()
            val dest = File(dir, filename)
            FileInputStream(source).use { input ->
                FileOutputStream(dest).use { out -> input.copyTo(out) }
            }
            MediaScannerConnection.scanFile(context, arrayOf(dest.absolutePath), arrayOf(mimeType), null)
            return "Movies/Virya/$filename"
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }
}

