package edu.ucsc.setlab.placemap

import android.content.Intent
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "edu.ucsc.setlab.placemap/native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "openCamera") {
                intent = Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA)
                context.startActivity(intent)
                result.success(null)
            }
        }
    }
}
