package com.abdurrouf.virya

import android.content.Intent
import com.abdurrouf.virya.focus.FocusChannel
import com.abdurrouf.virya.tasks.TaskChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var videoEncoder: VideoEncoderChannel? = null
    private var tasks: TaskChannel? = null
    private var focus: FocusChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        videoEncoder = VideoEncoderChannel(messenger)
        tasks = TaskChannel(this, messenger).also { it.handleIntent(intent) }
        focus = FocusChannel(this, messenger)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        tasks?.handleIntent(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        videoEncoder?.dispose()
        videoEncoder = null
        tasks?.dispose()
        tasks = null
        focus?.dispose()
        focus = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
