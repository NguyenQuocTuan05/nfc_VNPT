package com.vnpt.nfc_vnpt

import android.content.Intent
import android.os.Bundle
import com.google.gson.Gson
import com.vnptit.nfc.activity.VnptScanNFCActivity
import com.vnptit.nfc.constant.KeyIntentConstantsNFC
import com.vnptit.nfc.constant.SDKEnumNFC
import com.vnptit.nfc.model.NfcResult
import com.vnptit.nfc.model.NfcError
import com.vnptit.nfc.model.NfcOptionNoGuide
import com.vnptit.nfc.tool.NfcCallback
import com.vnptit.nfc.tool.NfcTool
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "vnpt_nfc_channel"
    }

    private lateinit var nfcTool: NfcTool
    private var pendingResult: MethodChannel.Result? = null

    // ─────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        nfcTool = NfcTool(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        nfcTool.clearReadChip()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        nfcTool.handleIntent(intent)
    }

    // ─────────────────────────────────────────────
    // Flutter MethodChannel
    // ─────────────────────────────────────────────

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMRZNFC" -> {
                    pendingResult = result

                    val accessToken = call.argument<String>("accessToken") ?: ""
                    val tokenId    = call.argument<String>("tokenId")    ?: ""
                    val tokenKey   = call.argument<String>("tokenKey")   ?: ""

                    startMRZNFC(accessToken, tokenId, tokenKey)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ─────────────────────────────────────────────
    // VNPT NFC SDK
    // ─────────────────────────────────────────────

    private fun startMRZNFC(accessToken: String, tokenId: String, tokenKey: String) {
        try {
            // Danh sách thông tin cần đọc từ chip
            val readingsNfcTags = arrayOf(
                SDKEnumNFC.ReadingNFCTags.MRZInfo.getValue(),
                SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.getValue(),
                SDKEnumNFC.ReadingNFCTags.AuthenticationInfo.getValue()
            )

            // Intent để cấu hình VnptScanNFCActivity (MRZ → NFC)
            val intent = Intent(this, VnptScanNFCActivity::class.java).apply {
                // Token xác thực
                putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN,      accessToken)
                putExtra(KeyIntentConstantsNFC.TOKEN_ID,          tokenId)
                putExtra(KeyIntentConstantsNFC.TOKEN_KEY,         tokenKey)
                putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN_EKYC, accessToken)
                putExtra(KeyIntentConstantsNFC.TOKEN_ID_EKYC,     tokenId)
                putExtra(KeyIntentConstantsNFC.TOKEN_KEY_EKYC,    tokenKey)

                // Cài đặt chung
                putExtra(KeyIntentConstantsNFC.LANGUAGE_SDK,
                    SDKEnumNFC.LanguageEnum.VIETNAMESE.getValue())
                putExtra(KeyIntentConstantsNFC.CHALLENGE_CODE,         "nfc")
                putExtra(KeyIntentConstantsNFC.IS_ENABLE_UPLOAD_IMAGE, true)
                putExtra(KeyIntentConstantsNFC.IS_ENABLE_GOT_IT,       true)
                putExtra(KeyIntentConstantsNFC.IS_SHOW_TUTORIAL,       true)

                // Các tag cần đọc
                putExtra(KeyIntentConstantsNFC.READING_TAGS_NFC, readingsNfcTags)
            }

            val nfcOption = NfcOptionNoGuide().setExtras(intent)

            nfcTool.startReadChip(nfcOption, object : NfcCallback() {
                override fun onSuccess(nfcResult: NfcResult) {
                    runOnUiThread {
                        val resultMap = buildResultMap(nfcResult)
                        pendingResult?.success(resultMap)
                        pendingResult = null
                    }
                }

                override fun onError(message: NfcError) {
                    super.onError(message)
                    runOnUiThread {
                        val errorCode = message.name
                        val errorMsg = when (message) {
                            NfcError.NOT_SUPPORT        -> "Thiết bị không hỗ trợ NFC"
                            NfcError.DISABLE            -> "NFC đang bị tắt. Vui lòng bật NFC và thử lại"
                            NfcError.OPEN_FAILURE       -> "Không truy cập được chip NFC trên thẻ"
                            NfcError.AUTHENTICATE_FAILURE -> "Xác thực thẻ thất bại (số CCCD không đúng)"
                            NfcError.READ_DATA_FAILURE  -> "Lỗi trong quá trình đọc thẻ"
                            NfcError.TIME_OUT_START_READ_NFC -> "Hết thời gian chờ đặt thẻ vào máy"
                            NfcError.TIME_OUT_NETWORK   -> "Lỗi kết nối mạng"
                            NfcError.DOCUMENT_NUMBER_INVALID -> "Số CCCD không hợp lệ (cần 12 chữ số)"
                            NfcError.DATE_OF_BIRTH_INVALID   -> "Ngày sinh không hợp lệ"
                            NfcError.DATE_OF_EXPIRY_INVALID  -> "Ngày hết hạn không hợp lệ"
                            else -> "Lỗi không xác định: $errorCode"
                        }
                        pendingResult?.error(errorCode, errorMsg, null)
                        pendingResult = null
                    }
                }
            })

        } catch (e: Exception) {
            e.printStackTrace()
            pendingResult?.error("SDK_EXCEPTION", e.message ?: "Lỗi không xác định", null)
            pendingResult = null
        }
    }

    // ─────────────────────────────────────────────
    // Parse NfcResult → Map để gửi về Flutter
    // ─────────────────────────────────────────────

    private fun buildResultMap(nfcResult: NfcResult): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()

        // Raw JSON từ chip
        nfcResult.logNfcResult?.let { map["logNfcResult"] = it }

        // Parse logNfcResult để lấy các trường CCCD
        try {
            val logJson = Gson().fromJson(nfcResult.logNfcResult, Map::class.java)
            logJson?.forEach { (k, v) -> map["log_$k"] = v }
        } catch (_: Exception) {}

        // Các trường chính
        map["hashAvatar"]                  = nfcResult.hashAvatar
        map["verifyChipResult"]            = nfcResult.verifyChipResult
        map["imgFaceCardPath"]             = nfcResult.imgFaceCardPath
        map["clientSessionNfc"]            = nfcResult.clientSessionNfc
        map["dataGroupsResult"]            = nfcResult.dataGroupsResult
        map["postCodeOriginalLocation"]    = nfcResult.postCodeOriginalLocationResult
        map["postCodeRecentLocation"]      = nfcResult.postCodeRecentLocationResult
        map["statusChipAuthentication"]    = nfcResult.statusChipAuthentication
        map["statusChipActiveAuthentication"] = nfcResult.statusChipActiveAuthentication

        return map
    }
}
