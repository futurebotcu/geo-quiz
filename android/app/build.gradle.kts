import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
var hasValidKeystore = false
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
    // Check if passwords have been updated from placeholders
    val storePass = keystoreProperties.getProperty("storePassword", "")
    hasValidKeystore = storePass.isNotEmpty() && !storePass.contains("YOUR_") && !storePass.contains("PASSWORD_HERE")
}

android {
    namespace = "com.worldgeo.quiz"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.worldgeo.quiz"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        ndk {
            // arm64-v8a: 64-bit ARM (modern Android phones, 98%+ of active devices)
            // x86_64:    64-bit x86 (emulators, Chromebooks)
            // armeabi-v7a excluded: NDK 27 + CMake 3.22.1 Windows bug; not needed for minSdk 21+
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    signingConfigs {
        if (hasValidKeystore) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if valid keystore exists, otherwise fall back to debug
            signingConfig = if (hasValidKeystore) {
                signingConfigs.getByName("release")
            } else {
                println("⚠️  Using debug signing for release build (keystore not configured)")
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    // A plugin (shared_preferences_android) ships a stub armeabi-v7a lib
    // while the Flutter engine is compiled only for arm64-v8a + x86_64.
    // That stub makes the bundle advertise a 32-bit ABI we don't actually
    // serve — causing install/launch failures on legacy devices. Drop it.
    packaging {
        jniLibs {
            excludes += "**/armeabi-v7a/**"
        }
    }
}

flutter {
    source = "../.."
}
