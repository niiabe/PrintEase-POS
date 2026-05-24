package com.example.print_ease_pos

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

class BluetoothPrinterService(private val context: Context) {
    companion object {
        private const val SPP_UUID = "00001101-0000-1000-8000-00805F9B34FB"
        private const val STATE_IDLE = 0
        private const val STATE_CONNECTING = 1
        private const val STATE_CONNECTED = 2
        private const val STATE_CLOSING = 3
        private const val MAX_RETRIES = 3
        private const val RETRY_DELAY_MS = 1000L
    }

    private var state = STATE_IDLE
    private var bluetoothSocket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var inputStream: InputStream? = null
    private var currentDevice: BluetoothDevice? = null
    private var pendingResult: MethodChannel.Result? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var discoveryReceiver: BroadcastReceiver? = null

    fun isConnected(): Boolean = state == STATE_CONNECTED && bluetoothSocket?.isConnected == true

    fun getConnectedDeviceAddress(): String? = currentDevice?.address

    fun getConnectedDeviceName(): String? = currentDevice?.name

    fun discoverDevices(result: MethodChannel.Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null) {
            result.error("NO_BLUETOOTH", "Device does not support Bluetooth", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("BLUETOOTH_OFF", "Bluetooth is not enabled", null)
            return
        }

        val devices = mutableListOf<Map<String, String>>()
        val bondedDevices = adapter.bondedDevices
        bondedDevices?.forEach { device ->
            devices.add(mapOf(
                "name" to (device.name ?: "Unknown"),
                "address" to device.address
            ))
        }
        result.success(devices)
    }

    fun startDiscovery(result: MethodChannel.Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null || !adapter.isEnabled) {
            result.error("BLUETOOTH_OFF", "Bluetooth is not available", null)
            return
        }

        pendingResult = result
        val foundDevices = mutableSetOf<String>()
        val discoveredList = mutableListOf<Map<String, String>>()

        val bonded = adapter.bondedDevices
        bonded?.forEach { device ->
            val addr = device.address
            if (foundDevices.add(addr)) {
                discoveredList.add(mapOf(
                    "name" to (device.name ?: "Unknown"),
                    "address" to addr
                ))
            }
        }

        if (adapter.isDiscovering) {
            adapter.cancelDiscovery()
        }

        discoveryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothDevice.ACTION_FOUND -> {
                        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        if (device != null && device.name != null) {
                            val addr = device.address
                            if (foundDevices.add(addr)) {
                                discoveredList.add(mapOf(
                                    "name" to (device.name ?: "Unknown"),
                                    "address" to addr
                                ))
                                // Send incremental update via method channel?
                                // For now we just collect and return all at end
                            }
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        // Discovery cycle finished, but we might still have more time
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        context.registerReceiver(discoveryReceiver, filter)
        adapter.startDiscovery()

        mainHandler.postDelayed({
            try { context.unregisterReceiver(discoveryReceiver) } catch (_: Exception) {}
            discoveryReceiver = null
            if (adapter.isDiscovering) {
                adapter.cancelDiscovery()
            }
            result.success(discoveredList.toList())
            pendingResult = null
        }, 12000L)
    }

    fun connect(address: String, result: MethodChannel.Result) {
        if (state == STATE_CONNECTED) {
            result.success(true)
            return
        }

        val adapter = BluetoothAdapter.getDefaultAdapter() ?: run {
            result.error("NO_BLUETOOTH", "Bluetooth not supported", null)
            return
        }

        val device = adapter.getRemoteDevice(address) ?: run {
            result.error("DEVICE_NOT_FOUND", "Device not found: $address", null)
            return
        }

        pendingResult = result
        currentDevice = device
        state = STATE_CONNECTING

        connectThread(device, 0)
    }

    private fun connectThread(device: BluetoothDevice, retryCount: Int) {
        Thread {
            try {
                val socket = device.createRfcommSocketToServiceRecord(UUID.fromString(SPP_UUID))
                bluetoothSocket = socket

                val adapter = BluetoothAdapter.getDefaultAdapter()
                adapter?.cancelDiscovery()

                socket.connect()

                outputStream = socket.outputStream
                inputStream = socket.inputStream
                state = STATE_CONNECTED

                mainHandler.post {
                    pendingResult?.success(true)
                    pendingResult = null
                }
            } catch (e: IOException) {
                closeQuietly()
                if (retryCount < MAX_RETRIES) {
                    Thread.sleep(RETRY_DELAY_MS)
                    connectThread(device, retryCount + 1)
                } else {
                    state = STATE_IDLE
                    mainHandler.post {
                        pendingResult?.error("CONNECT_FAILED", "Failed after $MAX_RETRIES retries: ${e.message}", null)
                        pendingResult = null
                    }
                }
            }
        }.start()
    }

    fun disconnect() {
        closeQuietly()
        currentDevice = null
        state = STATE_IDLE
    }

    fun writeBytes(bytes: ByteArray, result: MethodChannel.Result) {
        if (state != STATE_CONNECTED) {
            result.error("NOT_CONNECTED", "Printer not connected", null)
            return
        }

        Thread {
            try {
                outputStream?.write(bytes)
                outputStream?.flush()
                mainHandler.post { result.success(true) }
            } catch (e: IOException) {
                state = STATE_IDLE
                mainHandler.post { result.error("WRITE_FAILED", "Write failed: ${e.message}", null) }
            }
        }.start()
    }

    fun printTestReceipt(storeName: String, result: MethodChannel.Result) {
        val bytes = buildTestReceiptBytes(storeName)
        writeBytes(bytes, result)
    }

    private fun buildTestReceiptBytes(storeName: String): ByteArray {
        val bytes = mutableListOf<Byte>()

        bytes.addAll(byteArrayOf(0x1B, 0x40).toList()) // init
        bytes.addAll(byteArrayOf(0x1B, 0x61, 0x01).toList()) // center
        bytes.addAll(byteArrayOf(0x1B, 0x21, 0x30).toList()) // double width + double height
        bytes.addAll("TEST PRINT\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll(byteArrayOf(0x1B, 0x21, 0x00).toList()) // normal size
        bytes.addAll("$storeName\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("================================\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll(byteArrayOf(0x1B, 0x61, 0x00).toList()) // left
        bytes.addAll("Printer Connection: OK\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("Date: ${java.text.SimpleDateFormat("yyyy-MM-dd HH:mm", java.util.Locale.getDefault()).format(java.util.Date())}\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("================================\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll(byteArrayOf(0x1B, 0x61, 0x01).toList()) // center
        bytes.addAll("If you can read this,\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("your printer is working!\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll("\n\n".toByteArray(Charsets.UTF_8).toList())
        bytes.addAll(byteArrayOf(0x1D, 0x56, 0x00).toList()) // cut

        return bytes.toByteArray()
    }

    fun printRawBytes(data: ByteArray, result: MethodChannel.Result) {
        writeBytes(data, result)
    }

    private fun closeQuietly() {
        try {
            outputStream?.close()
        } catch (_: IOException) {}
        try {
            inputStream?.close()
        } catch (_: IOException) {}
        try {
            bluetoothSocket?.close()
        } catch (_: IOException) {}
        outputStream = null
        inputStream = null
        bluetoothSocket = null
        state = STATE_IDLE
    }

    fun cleanup() {
        disconnect()
        discoveryReceiver?.let {
            try { context.unregisterReceiver(it) } catch (_: Exception) {}
            discoveryReceiver = null
        }
    }
}
