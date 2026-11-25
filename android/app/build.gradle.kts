import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abdurrouf.virya"
    compileSdk = 35
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.abdurrouf.virya"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Kunci release TIDAK disimpan di repo. Sumbernya (urutan prioritas):
    //   1. android/key.properties (lokal, di-gitignore)
    //   2. env VIRYA_KEYSTORE_PATH / _PASSWORD / VIRYA_KEY_ALIAS / VIRYA_KEY_PASSWORD (CI)
    // Kalau keduanya tidak ada, build release jatuh ke debug key supaya
    // `flutter run --release` tetap jalan di mesin tim.
    val keyProps = Properties().apply {
        val f = rootProject.file("key.properties")
        if (f.exists()) f.inputStream().use { load(it) }
    }
    fun signingValue(prop: String, env: String): String? =
        keyProps.getProperty(prop) ?: System.getenv(env)?.takeIf { it.isNotBlank() }

    val releaseStoreFile = signingValue("storeFile", "VIRYA_KEYSTORE_PATH")
    val hasReleaseKey = releaseStoreFile != null && file(releaseStoreFile).exists()

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = signingValue("storePassword", "VIRYA_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "VIRYA_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "VIRYA_KEY_PASSWORD")
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
            isMinifyEnabled = true
            isShrinkResources = true
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
