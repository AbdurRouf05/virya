package com.stravo.stravo

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import java.io.File
import java.nio.ByteBuffer

/**
 * H.264 (video/avc) encoder: RGBA frames -> YUV420 (BT.601, limited range)
 * via getInputImage() planes -> MediaCodec -> MediaMuxer MP4.
 * Not thread-safe: use from a single (background) thread.
 */
class Mp4Encoder(
    private val outputPath: String,
    requestedWidth: Int,
    requestedHeight: Int,
    private val fps: Int,
    private val bitrate: Int,
) {
    /** Encoded size, rounded down to multiples of 16. */
    val width: Int = (requestedWidth / 16) * 16
    val height: Int = (requestedHeight / 16) * 16

    private var codec: MediaCodec? = null
    private var muxer: MediaMuxer? = null
    private var track = -1
    private var muxerStarted = false
    private var frameIndex = 0L
    private var released = false
    private val info = MediaCodec.BufferInfo()
    private var yArr = ByteArray(0)
    private var uArr = ByteArray(0)
    private var vArr = ByteArray(0)
    private val threads = maxOf(2, Runtime.getRuntime().availableProcessors() - 1)
    private val pool = java.util.concurrent.Executors.newFixedThreadPool(threads)

    init {
        require(width >= 16 && height >= 16) { "Ukuran video terlalu kecil" }
        require(fps in 1..120) { "fps tidak valid" }
    }

    fun start() {
        File(outputPath).parentFile?.mkdirs()
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible
            )
            setInteger(MediaFormat.KEY_BIT_RATE, bitrate)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        val c = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        try {
            c.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            c.start()
        } catch (e: Exception) {
            c.release()
            throw e
        }
        codec = c
        muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
    }

    /** [rgba] is srcW*srcH*4 straight RGBA; center-cropped/padded to the encoded size. */
    fun addFrameRgba(rgba: ByteArray, srcW: Int, srcH: Int) {
        require(rgba.size >= srcW * srcH * 4) { "Buffer RGBA terlalu kecil" }
        val c = codec ?: throw IllegalStateException("Encoder belum dimulai")
        val index = dequeueInput(c)
        val image = c.getInputImage(index) ?: throw IllegalStateException("Input image null")
        try {
            fillYuv(image, rgba, srcW, srcH)
        } finally {
            image.close()
        }
        val pts = frameIndex * 1_000_000L / fps
        c.queueInputBuffer(index, 0, width * height * 3 / 2, pts, 0)
        frameIndex++
        drain(false)
    }

    /** PNG or JPEG bytes; scaled to (dstW x dstH) if needed. */
    fun addFrameImage(bytes: ByteArray, dstW: Int, dstH: Int) {
        val opts = BitmapFactory.Options().apply { inPreferredConfig = Bitmap.Config.ARGB_8888 }
        val decoded = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, opts)
            ?: throw IllegalArgumentException("Gambar tidak bisa didecode")
        var bmp = decoded
        if (bmp.width != dstW || bmp.height != dstH) {
            bmp = Bitmap.createScaledBitmap(decoded, dstW, dstH, true)
            if (bmp !== decoded) decoded.recycle()
        }
        if (bmp.config != Bitmap.Config.ARGB_8888) {
            val conv = bmp.copy(Bitmap.Config.ARGB_8888, false)
            bmp.recycle()
            bmp = conv
        }
        // ARGB_8888 is stored as R,G,B,A bytes in memory.
        val buf = ByteBuffer.allocate(dstW * dstH * 4)
        bmp.copyPixelsToBuffer(buf)
        bmp.recycle()
        addFrameRgba(buf.array(), dstW, dstH)
    }

    fun finish(): String {
        val c = codec ?: throw IllegalStateException("Encoder belum dimulai")
        if (frameIndex == 0L) throw IllegalStateException("Belum ada frame")
        val index = dequeueInput(c)
        val pts = frameIndex * 1_000_000L / fps
        c.queueInputBuffer(index, 0, 0, pts, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
        drain(true)
        val ok = muxerStarted
        release(deleteOutput = !ok)
        if (!ok) throw IllegalStateException("Tidak ada data video yang dihasilkan")
        return outputPath
    }

    fun cancel() {
        release(deleteOutput = true)
    }

    private fun dequeueInput(c: MediaCodec): Int {
        val deadline = System.nanoTime() + 5_000_000_000L
        while (true) {
            val i = c.dequeueInputBuffer(10_000)
            if (i >= 0) return i
            drain(false)
            if (System.nanoTime() > deadline) throw IllegalStateException("Encoder macet (input)")
        }
    }

    private fun drain(endOfStream: Boolean) {
        val c = codec ?: return
        val deadline = System.nanoTime() + 10_000_000_000L
        while (true) {
            val i = c.dequeueOutputBuffer(info, if (endOfStream) 10_000 else 0)
            when {
                i == MediaCodec.INFO_TRY_AGAIN_LATER -> {
                    if (!endOfStream) return
                    if (System.nanoTime() > deadline) throw IllegalStateException("Encoder macet (EOS)")
                }
                i == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    check(!muxerStarted) { "Format output berubah dua kali" }
                    val m = muxer!!
                    track = m.addTrack(c.outputFormat)
                    m.start()
                    muxerStarted = true
                }
                i >= 0 -> {
                    val buf = c.getOutputBuffer(i)
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                        info.size = 0 // already in the format (csd-0/1)
                    }
                    if (info.size > 0 && buf != null) {
                        check(muxerStarted) { "Muxer belum mulai" }
                        buf.position(info.offset)
                        buf.limit(info.offset + info.size)
                        muxer!!.writeSampleData(track, buf, info)
                    }
                    c.releaseOutputBuffer(i, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                }
                else -> { /* deprecated INFO_OUTPUT_BUFFERS_CHANGED */ }
            }
        }
    }

    /** RGBA -> YUV420 (BT.601 limited range), parallel chroma-band conversion + bulk copy. */
    private fun fillYuv(image: android.media.Image, rgba: ByteArray, srcW: Int, srcH: Int) {
        val w = minOf(width, image.width)
        val h = minOf(height, image.height)
        val cw = w / 2
        val ch = h / 2
        if (yArr.size < w * h) yArr = ByteArray(w * h)
        if (uArr.size < cw * ch) { uArr = ByteArray(cw * ch); vArr = ByteArray(cw * ch) }
        val offX = (srcW - w) / 2
        val offY = (srcH - h) / 2

        // Tahap A: paralel per pita baris chroma.
        val band = (ch + threads - 1) / threads
        val jobs = (0 until threads).map { t ->
            pool.submit {
                val cj0 = t * band
                val cj1 = minOf(ch, cj0 + band)
                for (cj in cj0 until cj1) {
                    for (dy in 0..1) {
                        val j = cj * 2 + dy
                        val sy = j + offY
                        val rowOk = sy in 0 until srcH
                        for (i in 0 until w) {
                            val sx = i + offX
                            var r = 0; var g = 0; var b = 0
                            if (rowOk && sx in 0 until srcW) {
                                val p = (sy * srcW + sx) * 4
                                r = rgba[p].toInt() and 0xFF
                                g = rgba[p + 1].toInt() and 0xFF
                                b = rgba[p + 2].toInt() and 0xFF
                            }
                            yArr[j * w + i] = (((66 * r + 129 * g + 25 * b + 128) shr 8) + 16).toByte()
                            if (dy == 0 && (i and 1) == 0 && (i shr 1) < cw) {
                                val u = ((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128
                                val v = ((112 * r - 94 * g - 18 * b + 128) shr 8) + 128
                                uArr[cj * cw + (i shr 1)] = u.coerceIn(0, 255).toByte()
                                vArr[cj * cw + (i shr 1)] = v.coerceIn(0, 255).toByte()
                            }
                        }
                    }
                }
            }
        }
        jobs.forEach { it.get() }

        // Tahap B: salin ke plane.
        val planes = image.planes
        val yP = planes[0]; val uP = planes[1]; val vP = planes[2]
        val yBuf = yP.buffer; val uBuf = uP.buffer; val vBuf = vP.buffer
        if (yP.pixelStride == 1) {
            for (j in 0 until h) { yBuf.position(j * yP.rowStride); yBuf.put(yArr, j * w, w) }
        } else {
            for (j in 0 until h) for (i in 0 until w)
                yBuf.put(j * yP.rowStride + i * yP.pixelStride, yArr[j * w + i])
        }
        for (cj in 0 until ch) {
            val ur = cj * uP.rowStride; val vr = cj * vP.rowStride
            for (ci in 0 until cw) {
                uBuf.put(ur + ci * uP.pixelStride, uArr[cj * cw + ci])
                vBuf.put(vr + ci * vP.pixelStride, vArr[cj * cw + ci])
            }
        }
    }

    private fun release(deleteOutput: Boolean) {
        if (released) return
        released = true
        try {
            pool.shutdown()
        } catch (ignored: Exception) {
        }
        try {
            codec?.stop()
        } catch (ignored: Exception) {
        }
        try {
            codec?.release()
        } catch (ignored: Exception) {
        }
        codec = null
        try {
            if (muxerStarted) muxer?.stop()
        } catch (ignored: Exception) {
        }
        try {
            muxer?.release()
        } catch (ignored: Exception) {
        }
        muxer = null
        if (deleteOutput || !muxerStarted) {
            try {
                File(outputPath).delete()
            } catch (ignored: Exception) {
            }
        }
    }
}
