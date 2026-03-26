package com.vnpt.nfc_vnpt

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import com.vnptit.nfc.activity.VnptScanNFCActivity
import com.vnptit.nfc.utils.KeyIntentConstantsNFC
import com.vnptit.nfc.utils.KeyResultConstantsNFC
import com.vnptit.nfc.utils.SDKEnumNFC

/**
 * Activity trung gian — extends AppCompatActivity.
 * MainActivity (FlutterActivity) start activity này qua startActivityForResult.
 */
class NfcHelperActivity : AppCompatActivity() {

    companion object {
        private const val REQUEST_CODE_NFC = 1
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val accessToken = intent.getStringExtra("accessToken") ?: ""
        val tokenId     = intent.getStringExtra("tokenId")    ?: ""
        val tokenKey    = intent.getStringExtra("tokenKey")   ?: ""

        startMRZNFC(accessToken, tokenId, tokenKey)
    }

    private fun startMRZNFC(accessToken: String, tokenId: String, tokenKey: String) {
        try {
            val intent = Intent(this, VnptScanNFCActivity::class.java).apply {
                putExtra(KeyIntentConstantsNFC.LANGUAGE_SDK, "vi")
                putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, accessToken)
                putExtra(KeyIntentConstantsNFC.TOKEN_ID, tokenId)
                putExtra(KeyIntentConstantsNFC.TOKEN_KEY, tokenKey)
                putExtra(KeyIntentConstantsNFC.IS_ENABLE_UPLOAD_IMAGE, false)
                putExtra(KeyIntentConstantsNFC.READER_CARD_MODE,
                    SDKEnumNFC.ReaderCardMode.MRZ_CODE.getValue())
                putExtra(KeyIntentConstantsNFC.BASE_URL, "")
            }
            startActivityForResult(intent, REQUEST_CODE_NFC)
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

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_CODE_NFC) return

        if (resultCode == Activity.RESULT_OK && data != null) {
            val resultIntent = Intent()

            // Lấy dữ liệu đầu ra theo KeyResultConstantsNFC
            val hashAvatar = data.getStringExtra(KeyResultConstantsNFC.HASH_IMAGE_AVATAR) ?: ""
            val avatarPath = data.getStringExtra(KeyResultConstantsNFC.PATH_IMAGE_AVATAR) ?: ""
            val clientSession = data.getStringExtra(KeyResultConstantsNFC.CLIENT_SESSION_RESULT) ?: ""
            val fullResponseNFC = data.getStringExtra(KeyResultConstantsNFC.DATA_NFC_RESULT) ?: ""
            val postCodeOriginalLocation = data.getStringExtra(
                KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT) ?: ""
            val postCodeRecentLocation = data.getStringExtra(
                KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT) ?: ""

            resultIntent.putExtra("hashAvatar", hashAvatar)
            resultIntent.putExtra("avatarPath", avatarPath)
            resultIntent.putExtra("clientSession", clientSession)
            resultIntent.putExtra("fullResponseNFC", fullResponseNFC)
            resultIntent.putExtra("postCodeOriginalLocation", postCodeOriginalLocation)
            resultIntent.putExtra("postCodeRecentLocation", postCodeRecentLocation)

            // Parse fullResponseNFC JSON và thêm các trường vào Intent
            if (fullResponseNFC.isNotEmpty()) {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val parsed = Gson().fromJson(fullResponseNFC, Map::class.java)
                            as? Map<String, Any>
                    parsed?.forEach { (k, v) ->
                        resultIntent.putExtra(k, v.toString())
                    }
                } catch (_: Exception) {}
            }

            setResult(RESULT_OK, resultIntent)
        } else {
            val resultIntent = Intent().apply {
                putExtra("errorCode", data?.getStringExtra("errorCode") ?: "UNKNOWN")
                putExtra("errorMessage", data?.getStringExtra("errorMessage") ?: "Người dùng huỷ hoặc có lỗi")
            }
            setResult(RESULT_CANCELED, resultIntent)
        }
        finish()
    }
}
