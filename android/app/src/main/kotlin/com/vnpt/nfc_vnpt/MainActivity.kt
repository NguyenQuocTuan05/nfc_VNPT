package com.vnpt.nfc_vnpt

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "vnpt_nfc_channel"
        const val REQUEST_NFC = 1001
        var pendingResult: MethodChannel.Result? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMRZNFC" -> {
                    pendingResult = result
                    val intent = Intent(this, NfcHelperActivity::class.java).apply {
                        putExtra("accessToken", call.argument<String>("accessToken") ?: "")
                        putExtra("tokenId",     call.argument<String>("tokenId")    ?: "")
                        putExtra("tokenKey",    call.argument<String>("tokenKey")   ?: "")
                    }
                    startActivityForResult(intent, REQUEST_NFC)
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_NFC) {
            if (resultCode == RESULT_OK && data != null) {
                val resultMap = mutableMapOf<String, Any?>()
                data.extras?.keySet()?.forEach { key ->
                    resultMap[key] = data.extras?.get(key)
                }
                pendingResult?.success(resultMap)
            } else {
                val errorMsg = data?.getStringExtra("errorMessage") ?: "Người dùng huỷ hoặc lỗi"
                val errorCode = data?.getStringExtra("errorCode") ?: "CANCELED"
                pendingResult?.error(errorCode, errorMsg, null)
            }
            pendingResult = null
        }
    }
}
