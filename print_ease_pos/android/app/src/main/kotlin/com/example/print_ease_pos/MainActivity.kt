package com.example.print_ease_pos

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.print_ease_pos/bluetooth"
        ).setMethodCallHandler { call, result ->
            if (call.method == "requestBluetoothEnable") {
                try {
                    val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
