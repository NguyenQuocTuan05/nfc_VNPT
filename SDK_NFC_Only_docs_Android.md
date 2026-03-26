* **Yêu cầu: minSDK 21**

1. **Giải nén file zip**  
2. **Copy file vnpt\_nfc\_sdk-release-v1.7.0.aar vào thư mục app/libs của dự án Android**  
3. **Mở app/build.gradle, thêm các dependencies**

implementation fileTree(dir: "libs", include: \["\*.jar", "\*.aar"\])  
implementation files('libs/vnpt\_nfc\_sdk-relase-v1.6.17.aar')

implementation 'com.google.code.gson:gson:2.8.6'  
implementation 'com.squareup.okhttp3:okhttp:4.9.0'  
implementation 'org.jmrtd:jmrtd:0.7.24'  
implementation 'com.madgag.spongycastle:prov:1.58.0.0'  
implementation 'net.sf.scuba:scuba-sc-android:0.0.23'  
implementation 'org.ejbca.cvc:cert-cvc:1.4.6'  
implementation 'org.bouncycastle:bcpkix-jdk15on:1.67'

	

0. **Mở app/proguard-rules.pro, thêm các dòng sau**

\-keep public class org.jmrtd.\* {  
  *\<fields\>*;  
  *\<methods\>*;  
}  
\-dontwarn org.jmrtd.\*  
\-keepattributes Exceptions, Signature, InnerClasses  
\-keep class org.jmrtd.JMRTDSecurityProvider\*\*  
\-keepclassmembers class org.jmrtd.JMRTDSecurityProvider\*\* {  
    \*;  
}

\-keep public class org.spongycastle.\* {  
  *\<fields\>*;  
  *\<methods\>*;  
}  
\-dontwarn org.spongycastle.\*  
\-keepattributes Exceptions, Signature, InnerClasses

\-keep public class org.ejbca.\* {  
  *\<fields\>*;  
  *\<methods\>*;  
}  
\-dontwarn org.ejbca.\*  
\-keepattributes Exceptions, Signature, InnerClasses

\-keep class org.bouncycastle.\*\* {\*;}

\#\#---------------Begin: proguard configuration for Gson  \----------  
\# Gson uses generic type information stored in a class file when working with fields. Proguard  
\# removes such information by default, so configure it to keep all of it.  
\-keepattributes Signature

\# For using GSON @Expose annotation  
\-keepattributes \*Annotation\*

\# Gson specific classes  
\-dontwarn sun.misc.\*\*  
\#-keep class com.google.gson.stream.\*\* { \*; }

\# Application classes that will be serialized/deserialized over Gson  
\-keep class com.google.gson.examples.android.model.\*\* { *\<fields\>*; }

\# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,  
\# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)  
\-keep class \* implements com.google.gson.TypeAdapter  
\-keep class \* implements com.google.gson.TypeAdapterFactory  
\-keep class \* implements com.google.gson.JsonSerializer  
\-keep class \* implements com.google.gson.JsonDeserializer

\# Prevent R8 from leaving Data object members always null  
\-keepclassmembers,allowobfuscation class \* {  
 @com.google.gson.annotations.SerializedName *\<fields\>*;  
}

\#\#---------------End: proguard configuration for Gson  \----------

0. **Sử dụng SDK**

   5.1. Khởi tạo đối tượng nfcTool

      private NfcTool nfcTool;

      override fun onCreate(savedInstanceState: Bundle?) {

          super.onCreate(savedInstanceState)

          setContentView(R.layout.*activity\_main*)

          nfcTool \= new NfcTool(this);

   **   **}

   5.2. Cài đặt onDestroy và onHandleIntent của activity

   

      override fun onDestroy() {

          super.onDestroy()

          nfcTool.clearReadChip()

      }

 


      override fun onNewIntent(intent: Intent?) {

          super.onNewIntent(intent)

          nfcTool.handleIntent(intent)

      }

   5.3. Start read chip

   public void startReadChip(NfcOptionNoGuide nfcOptionNoGuide, NfcCallback callback){}

* nfcOptionNoGuide: object chứa Các option truyền vào SDK để đọc chip  
* callback: callback

Ví dụ sử dụng: 

try {  
   List\<Integer\> readingsNfcTags \= new ArrayList\<\>();

   if (scanMRZ) {  
       readingsNfcTags.add(SDKEnumNFC.ReadingNFCTags.*MRZInfo*.getValue());  
   }

   if (scanImage) {  
       readingsNfcTags.add(SDKEnumNFC.ReadingNFCTags.*ImageAvatarInfo*.getValue());  
   }

   if (scanVerifyDocument) {  
       readingsNfcTags.add(SDKEnumNFC.ReadingNFCTags.*VerifyDocumentInfo*.getValue());  
   }

   readingsNfcTags.add(SDKEnumNFC.ReadingNFCTags.*AuthenticationInfo*.getValue());

   Intent intent \= new Intent(activity, VnptScanNFCActivity.class);  
   intent.putExtra(KeyIntentConstantsNFC.*LANGUAGE\_SDK*, AppCode.*language*);  
   intent.putExtra(KeyIntentConstantsNFC.*ACCESS\_TOKEN*, AppCode.*access\_token*);  
   intent.putExtra(KeyIntentConstantsNFC.*TOKEN\_ID*, AppCode.*token\_id*);  
   intent.putExtra(KeyIntentConstantsNFC.*TOKEN\_KEY*, AppCode.*token\_key*);

   intent.putExtra(KeyIntentConstantsNFC.*ACCESS\_TOKEN\_EKYC*, AppCode.*access\_token*);  
   intent.putExtra(KeyIntentConstantsNFC.*TOKEN\_ID\_EKYC*, AppCode.*token\_id*);  
   intent.putExtra(KeyIntentConstantsNFC.*TOKEN\_KEY\_EKYC*, AppCode.*token\_key*);

   intent.putExtra(KeyIntentConstantsNFC.*LANGUAGE\_SDK*, SDKEnumNFC.LanguageEnum.*VIETNAMESE*.getValue());  
   intent.putExtra(KeyIntentConstantsNFC.*CHALLENGE\_CODE*, "nfc");  
   intent.putExtra(KeyIntentConstantsNFC.*IS\_ENABLE\_UPLOAD\_IMAGE*, true);  
   intent.putExtra(KeyIntentConstantsNFC.*IS\_ENABLE\_GOT\_IT*, true);  
   intent.putExtra(KeyIntentConstantsNFC.*IS\_SHOW\_TUTORIAL*, true);  
   intent.putExtra(KeyIntentConstantsNFC.*ID\_NUMBER\_CARD*, "001097021412");  
   intent.putExtra(KeyIntentConstantsNFC.*BIRTHDAY\_CARD*, "970902");  
   intent.putExtra(KeyIntentConstantsNFC.*EXPIRED\_DATE\_CARD*, "370902");  
   intent.putExtra(KeyIntentConstantsNFC.*READING\_TAGS\_NFC*, readingsNfcTags.toArray());

     
} catch (Exception e) {  
   e.printStackTrace();  
}

final NfcOptionNoGuide nfcOptionNoGuide \= new NfcOptionNoGuide()  
    .setExtras(intent);

nfcTool.startReadChip(nfcOptionNoGuide, new NfcCallback() {  
    @Override  
    public void onSuccess(NfcResult nfcResult) {  
        runOnUiThread(new Runnable() {  
            @Override  
            public void run() {  
                dismissLoadingDialog();  
                showDialog(new Gson().toJson(nfcResult));  
            }  
        });  
    }

@Override  
public void onError(NfcError message) {  
    super.onError(message);  
    runOnUiThread(new Runnable() {  
        @Override  
        public void run() {  
            switch (message) {  
                case *NOT\_SUPPORT*:  
                    // Thiết bị không hỗ trợ NFC  
                    break;  
                case *DISABLE*:  
                    // Thiết bị có NFC nhưng đang tắt NFC  
                    break;  
                case *DOCUMENT\_NUMBER\_INVALID*:  
                    // Số căn cước phải bao gồm 12 chữ số  
                    break;  
                case *DATE\_OF\_BIRTH\_INVALID*:  
                    // Ngày sinh phải gồm 6 chữ số;  
                    break;  
                case *DATE\_OF\_EXPIRY\_INVALID*:  
                    // Ngày hết hạn phải gồm 6 chữ số  
                    break;  
                case *OPEN\_FAILURE*:  
                    // Ko truy cập được vào thẻ chip NFC  
                    break;  
                case *AUTHENTICATE\_FAILURE*:  
                    // Ko xác thực được thẻ chip NFC (thường do số giấy tờ ko đúng)  
                    break;  
                case *READ\_DATA\_FAILURE*:  
                    // Có lỗi trong quá trình đọc thẻ  
                    break;  
                case *TIME\_OUT\_START\_READ\_NFC*:  
                    // Hết thời gian chờ nhận thẻ chip NFC  
                    break;  
                case *TIME\_OUT\_NETWORK*:  
                    // Đường truyền mạng không kém  
                    break;  
                default:  
                    // Thẻ ko hợp lệ, ko đúng định dạng, ko phải thẻ chip trên căn cước  
                    break;  
            }  
        }  
    });  
}

	5.4 Thông tin mô tả input và output

5.4.1 Thông tin mô tả input option bên trong **NfcOptionNoGuide**

*/\*\**  
 *\* AccessToken nhận để authen*  
 *\*/*  
private String accessToken;

*/\*\**  
 *\* TokenId nhận để authen*  
 *\*/*  
private String tokenId;

*/\*\**  
 *\* TokenKey nhận để authen*  
 *\*/*  
private String tokenKey;

*/\*\**  
 *\* số định danh trên thẻ căn cước*  
 *\*/*  
private String documentNumber;

*/\*\**  
 *\* ngày sinh định dạng yy/MM/dd*  
 *\*/*  
private String dateOfBirth;

*/\*\**  
 *\* ngày hết hạn định dạng yy/MM/dd*  
 *\*/*  
private String dateOfExpiry;

*/\*\**  
 *\* option có upload ảnh trong thẻ để nhận hash*  
 *\*/*  
private boolean isEnableUploadImage;

private boolean isEnableMappingAddress;

*/\*\**  
 *\* option có xác thực chip ngay tại sdk*  
 *\*/*  
private boolean isEnableVerifyChip;

*/\*\**  
 *\* option kiểm tra căn cước có bị giả mạo*  
 *\*/*  
private boolean isCheckChipClone;

*/\*\**  
 *\* Thời gian chờ cho phép người dùng chạm thẻ vào điện thoại (s)*  
 *\*/*  
private int timerReadCard \= 60;

*/\*\**  
 *\* Thông tin trong thẻ cần đọc*  
 *\*/*  
private List\<Integer\> readingsNfcTags;

5.4.2 Thông tin mô tả Output trong object **NfcResult**

*/\*\**  
 *\* chuỗi json trả về chứa thông tin bên trong thẻ chip*  
 *\*/*  
private String logNfcResult;

private String clientSessionNfc;

*/\*\**  
 *\* thông tin hash ảnh khuôn mặt*  
 *\*/*  
private String hashAvatar;

*/\*\**  
 *\* chuỗi json postcode của quê quán*  
 *\*/*  
private String postCodeOriginalLocationResult;

*/\*\**  
 *\* chuỗi json postcode của nơi thường trú*  
 *\*/*  
private String postCodeRecentLocationResult;

*/\*\**  
 *\* kết quả xác thưc chip với c06*  
 *\*/*  
private String verifyChipResult;

*/\*\**  
 *\* đường dẫn ảnh khuôn mặt trong thẻ*  
 *\*/*  
private String imgFaceCardPath;

*/\*\**  
 *\* Chuỗi thông tin data groups trong thẻ*  
 *\*/*  
private String dataGroupsResult;

*/\*\**  
 *\* Thông tin xác thực chip CA để kiểm tra chip giả mạo*  
 *\*/*  
private String statusChipAuthentication;

*/\*\**  
 *\* Thông tin xác thực chip AA để kiểm tra chip giả mạo*  
 *\*/*  
private String statusChipActiveAuthentication;  
