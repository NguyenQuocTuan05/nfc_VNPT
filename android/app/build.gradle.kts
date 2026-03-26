plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vnpt.nfc_vnpt"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.vnpt.nfc_vnpt"
        // VNPT NFC SDK yêu cầu >=21, shared_preferences_android yêu cầu >=24
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // VNPT NFC SDK (AAR trong libs/)
    implementation(files("libs/vnpt_nfc_sdk-release-v1.8.0.aar"))
    implementation(files("libs/scanqr_ic_sdk-release-v1.0.6.aar"))

    // Dependencies của VNPT NFC SDK
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.android.material:material:1.9.0") // VNPT SDK cần BottomSheet styles
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.airbnb.android:lottie:3.0.3-support")
    implementation("com.squareup.okhttp3:okhttp:4.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.9.0")

    // NFC chip reading
    implementation("org.jmrtd:jmrtd:0.7.24")
    implementation("com.madgag.spongycastle:prov:1.58.0.0")
    implementation("net.sf.scuba:scuba-sc-android:0.0.23")
    implementation("org.ejbca.cvc:cert-cvc:1.4.6")
    implementation("org.bouncycastle:bcpkix-jdk15on:1.67")

    // QR / Camera
    implementation("com.google.zxing:core:3.5.1")
    implementation("androidx.camera:camera-core:1.2.1")
    implementation("androidx.camera:camera-camera2:1.2.1")
    implementation("androidx.camera:camera-lifecycle:1.2.1")
    implementation("androidx.camera:camera-view:1.2.1")
}
