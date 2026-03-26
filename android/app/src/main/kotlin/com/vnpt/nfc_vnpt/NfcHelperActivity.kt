package com.vnpt.nfc_vnpt

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import com.vnptit.nfc.activity.VnptScanNFCActivity
import com.vnptit.nfc.nfc_tool.NfcCallback
import com.vnptit.nfc.nfc_tool.NfcError
import com.vnptit.nfc.nfc_tool.NfcOptionNoGuide
import com.vnptit.nfc.nfc_tool.NfcResult
import com.vnptit.nfc.nfc_tool.NfcTool
import com.vnptit.nfc.utils.KeyIntentConstantsNFC
import com.vnptit.nfc.utils.SDKEnumNFC

/**
 * Activity trung gian — extends AppCompatActivity (yêu cầu của NfcTool).
 * MainActivity (FlutterActivity) start activity này qua startActivityForResult.
 */
class NfcHelperActivity : AppCompatActivity() {

    private lateinit var nfcTool: NfcTool

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val accessToken = intent.getStringExtra("accessToken") ?: ""
        val tokenId     = intent.getStringExtra("tokenId")    ?: ""
        val tokenKey    = intent.getStringExtra("tokenKey")   ?: ""

        nfcTool = NfcTool(this)
        startMRZNFC(accessToken, tokenId, tokenKey)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::nfcTool.isInitialized) nfcTool.clearReadChip()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (::nfcTool.isInitialized) nfcTool.handleIntent(intent)
    }

    private fun startMRZNFC(accessToken: String, tokenId: String, tokenKey: String) {
        try {
            val readingsNfcTags = arrayListOf(
                SDKEnumNFC.ReadingNFCTags.MRZInfo.getValue(),
                SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.getValue(),
                SDKEnumNFC.ReadingNFCTags.AuthenticationInfo.getValue()
            )

            val intent = Intent(this, VnptScanNFCActivity::class.java).apply {
                putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN,      accessToken)
                putExtra(KeyIntentConstantsNFC.TOKEN_ID,          tokenId)
                putExtra(KeyIntentConstantsNFC.TOKEN_KEY,         tokenKey)
                putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN_EKYC, accessToken)
                putExtra(KeyIntentConstantsNFC.TOKEN_ID_EKYC,     tokenId)
                putExtra(KeyIntentConstantsNFC.TOKEN_KEY_EKYC,    tokenKey)
                putExtra(KeyIntentConstantsNFC.READER_CARD_MODE,
                    SDKEnumNFC.ReaderCardMode.MRZ_CODE.getValue())
                putExtra(KeyIntentConstantsNFC.LANGUAGE_SDK,
                    SDKEnumNFC.LanguageEnum.VIETNAMESE.getValue())
                putExtra(KeyIntentConstantsNFC.CHALLENGE_CODE,         "nfc")
                putExtra(KeyIntentConstantsNFC.IS_ENABLE_UPLOAD_IMAGE, true)
                putExtra(KeyIntentConstantsNFC.IS_ENABLE_GOT_IT,       true)
                putExtra(KeyIntentConstantsNFC.IS_SHOW_TUTORIAL,       true)
                putExtra(KeyIntentConstantsNFC.READING_TAGS_NFC, readingsNfcTags.toTypedArray())
            }

            val nfcOption = NfcOptionNoGuide().setExtras(intent)

            nfcTool.startReadChip(nfcOption, object : NfcCallback() {
                override fun onSuccess(nfcResult: NfcResult) {
                    runOnUiThread {
                        val resultIntent = Intent()
                        // Trả về logNfcResult (JSON đầy đủ thông tin thẻ)
                        resultIntent.putExtra("logNfcResult",   nfcResult.logNfcResult)
                        resultIntent.putExtra("hashAvatar",     nfcResult.hashAvatar)
                        resultIntent.putExtra("hashDG",         nfcResult.hashDG)
                        resultIntent.putExtra("imgFaceCardPath",nfcResult.imgFaceCardPath)
                        resultIntent.putExtra("clientSessionNfc", nfcResult.clientSessionNfc)
                        resultIntent.putExtra("dataGroupsResult", nfcResult.dataGroupsResult)
                        resultIntent.putExtra("postCodeOriginalLocation",
                            nfcResult.postCodeOriginalLocationResult)
                        resultIntent.putExtra("postCodeRecentLocation",
                            nfcResult.postCodeRecentLocationResult)
                        resultIntent.putExtra("statusChipAuthentication",
                            nfcResult.statusChipAuthentication)
                        resultIntent.putExtra("statusChipActiveAuthentication",
                            nfcResult.statusChipActiveAuthentication)

                        // Parse logNfcResult JSON và thêm các trường vào Intent
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val parsed = Gson().fromJson(nfcResult.logNfcResult, Map::class.java)
                                    as? Map<String, Any>
                            parsed?.forEach { (k, v) ->
                                resultIntent.putExtra(k, v.toString())
                            }
                        } catch (_: Exception) {}

                        setResult(RESULT_OK, resultIntent)
                        finish()
                    }
                }

                override fun onError(message: NfcError) {
                    super.onError(message)
                    runOnUiThread {
                        val errorCode = message.toString()
                        val errorMsg = when (message) {
                            NfcError.NOT_SUPPORT             -> "Thiết bị không hỗ trợ NFC"
                            NfcError.DISABLE                 -> "NFC đang tắt"
                            NfcError.TAG_INVALID             -> "Thẻ không hợp lệ"
                            NfcError.NOT_CONNECTED_CHIP      -> "Không kết nối được chip NFC"
                            NfcError.FAILED_CONNECT_CHIP     -> "Kết nối chip NFC thất bại"
                            NfcError.AUTHENTICATE_FAILURE    -> "Xác thực thẻ thất bại"
                            NfcError.READ_DATA_FAILURE       -> "Lỗi đọc thẻ"
                            NfcError.TIME_OUT_START_READ_NFC -> "Hết thời gian chờ đặt thẻ"
                            NfcError.TIME_OUT_NETWORK        -> "Lỗi mạng"
                            NfcError.DOCUMENT_NUMBER_INVALID -> "Số CCCD không hợp lệ"
                            NfcError.DATE_OF_BIRTH_INVALID   -> "Ngày sinh không hợp lệ"
                            NfcError.DATE_OF_EXPIRY_INVALID  -> "Ngày hết hạn không hợp lệ"
                            NfcError.USER_CANCELED           -> "Người dùng huỷ"
                            NfcError.NFC_OPTION_NULL         -> "Cấu hình NFC null"
                            else                             -> errorCode
                        }
                        val resultIntent = Intent().apply {
                            putExtra("errorCode", errorCode)
                            putExtra("errorMessage", errorMsg)
                        }
                        setResult(RESULT_CANCELED, resultIntent)
                        finish()
                    }
                }
            })
        } catch (e: Exception) {
            e.printStackTrace()
            val resultIntent = Intent().apply {
                putExtra("errorCode", "SDK_EXCEPTION")
                putExtra("errorMessage", e.message ?: "Lỗi không xác định")
            }
            setResult(RESULT_CANCELED, resultIntent)
            finish()
        }
    }
}
