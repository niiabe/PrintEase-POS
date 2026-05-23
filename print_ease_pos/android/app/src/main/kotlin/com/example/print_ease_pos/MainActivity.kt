package com.example.print_ease_pos

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.BluetoothAdapter
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingBluetoothResult: MethodChannel.Result? = null
    private var pendingPermissions: Array<String>? = null
    private var permissionRequestCode = 1001
    private var bluetoothRequestCode = 2001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.print_ease_pos/bluetooth"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBluetoothEnable" -> {
                    pendingBluetoothResult = result
                    val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                    startActivityForResult(intent, bluetoothRequestCode)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.print_ease_pos/permissions"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkBluetoothConnect" -> {
                    result.success(hasPermission(Manifest.permission.BLUETOOTH_CONNECT))
                }
                "checkBluetoothScan" -> {
                    result.success(hasPermission(Manifest.permission.BLUETOOTH_SCAN))
                }
                "requestBluetoothConnect" -> {
                    pendingPermissionResult = result
                    requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), permissionRequestCode)
                }
                "requestBluetoothScan" -> {
                    pendingPermissionResult = result
                    requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_SCAN), permissionRequestCode)
                }
                "requestLocation" -> {
                    pendingPermissionResult = result
                    requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), permissionRequestCode)
                }
                "requestAllBluetoothPermissions" -> {
                    val permissions = mutableListOf<String>()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
                        permissions.add(Manifest.permission.BLUETOOTH_SCAN)
                    }
                    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                        permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
                    }
                    if (permissions.isEmpty()) {
                        result.success(true)
                    } else {
                        pendingPermissionResult = result
                        pendingPermissions = permissions.toTypedArray()
                        requestPermissions(permissions.toTypedArray(), permissionRequestCode)
                    }
                }
                "requestNotification" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pendingPermissionResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                            permissionRequestCode
                        )
                    } else {
                        result.success(true)
                    }
                }
                "requestMediaImages" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pendingPermissionResult = result
                        requestPermissions(
                            arrayOf(
                                Manifest.permission.READ_MEDIA_IMAGES,
                                Manifest.permission.READ_MEDIA_VIDEO
                            ),
                            permissionRequestCode
                        )
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        pendingPermissionResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                            permissionRequestCode
                        )
                    } else {
                        result.success(true)
                    }
                }
                "requestAllAppPermissions" -> {
                    val permissions = mutableListOf<String>()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
                        permissions.add(Manifest.permission.BLUETOOTH_SCAN)
                    }
                    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                        permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        permissions.add(Manifest.permission.POST_NOTIFICATIONS)
                        permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
                        permissions.add(Manifest.permission.READ_MEDIA_VIDEO)
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
                    }
                    if (permissions.isEmpty()) {
                        result.success(true)
                    } else {
                        pendingPermissionResult = result
                        pendingPermissions = permissions.toTypedArray()
                        requestPermissions(permissions.toTypedArray(), permissionRequestCode)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.print_ease_pos/pdf_save"
        ).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val path = call.argument<String>("path")
                val fileName = call.argument<String>("fileName")
                if (path == null || fileName == null) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                result.success(savePdfToPublicDownloads(path, fileName))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun hasPermission(permission: String): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S &&
            (permission == Manifest.permission.BLUETOOTH_CONNECT ||
             permission == Manifest.permission.BLUETOOTH_SCAN)) {
            true
        } else {
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun savePdfToPublicDownloads(filePath: String, fileName: String): String? {
        return try {
            val file = File(filePath)
            if (!file.exists()) return null

            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
            }

            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            if (uri == null) return null

            val outputStream = contentResolver.openOutputStream(uri)
            if (outputStream == null) {
                contentResolver.delete(uri, null, null)
                return null
            }

            outputStream.use { output ->
                file.inputStream().use { input ->
                    input.copyTo(output)
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
                contentResolver.update(uri, contentValues, null, null)
            }

            showDownloadNotification(uri, fileName)

            uri.toString()
        } catch (e: Exception) {
            null
        }
    }

    private fun showDownloadNotification(uri: Uri, fileName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
                return
            }
        }

        val channelId = "pdf_downloads"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "PDF Downloads",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications when PDF files are downloaded"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            pendingIntentFlags
        )

        val notificationId = System.currentTimeMillis().toInt()

        val notification = Notification.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle("PDF Downloaded")
            .setContentText("$fileName saved to Downloads")
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(notificationId, notification)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == bluetoothRequestCode) {
            val enabled = resultCode == RESULT_OK
            pendingBluetoothResult?.success(enabled)
            pendingBluetoothResult = null
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == permissionRequestCode) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingPermissionResult?.success(allGranted)
            pendingPermissionResult = null
            pendingPermissions = null
        }
    }

    override fun onDestroy() {
        pendingPermissionResult?.success(false)
        pendingPermissionResult = null
        pendingBluetoothResult?.success(false)
        pendingBluetoothResult = null
        super.onDestroy()
    }
}
