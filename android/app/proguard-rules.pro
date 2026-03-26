# ==================== VNPT NFC SDK ProGuard Rules ====================

# NFC - jmrtd
-keep public class org.jmrtd.* {
    <fields>;
    <methods>;
}
-dontwarn org.jmrtd.*
-keepattributes Exceptions, Signature, InnerClasses
-keep class org.jmrtd.JMRTDSecurityProvider** { *; }
-keepclassmembers class org.jmrtd.JMRTDSecurityProvider** { *; }

# SpongyCastle
-keep public class org.spongycastle.* {
    <fields>;
    <methods>;
}
-dontwarn org.spongycastle.*
-keepattributes Exceptions, Signature, InnerClasses

# SCUBA
-keep public class net.sf.scuba.* {
    <fields>;
    <methods>;
    *;
}
-dontwarn net.sf.scuba.*
-keepattributes Exceptions, Signature, InnerClasses
-keep class net.sf.scuba.smartcards.IsoDepCardService** { *; }
-keepclassmembers class net.sf.scuba.smartcards.IsoDepCardService** { *; }

# EJBCA CVC
-keep public class org.ejbca.* {
    <fields>;
    <methods>;
}
-dontwarn org.ejbca.*
-keepattributes Exceptions, Signature, InnerClasses

# Bouncy Castle
-keep class org.bouncycastle.** { *; }

# SLF4J (MRZ)
-keep public class org.slf4j.* {
    <fields>;
    <methods>;
}
-dontwarn org.slf4j.*
-keepattributes Exceptions, Signature, InnerClasses

# cz.adaptech (MRZ)
-keep public class cz.adaptech.android.* {
    <fields>;
    <methods>;
}
-dontwarn cz.adaptech.android.*
-keepattributes Exceptions, Signature, InnerClasses

# Retrofit / OkHttp
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# Gson
-keepattributes Signature
-keep class com.google.gson.** { *; }

# ==================== End VNPT NFC SDK ====================
