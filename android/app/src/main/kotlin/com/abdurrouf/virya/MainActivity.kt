package com.abdurrouf.virya

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var videoEncoder: VideoEncoderChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        videoEncoder = VideoEncoderChannel(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        videoEncoder?.dispose()
        videoEncoder = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
