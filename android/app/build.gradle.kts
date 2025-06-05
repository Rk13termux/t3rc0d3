plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tercode"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tercode"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        
        // 🎯 CORRECCIÓN: Aumentar minSdk para google_mobile_ads
        minSdk = 23  // Cambiado de flutter.minSdkVersion a 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Configuración para evitar problemas con font_awesome_flutter
        ndk {
            debugSymbolLevel = "NONE"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // ✅ CORRECCIÓN: Sintaxis correcta para Kotlin DSL
            isMinifyEnabled = false
            isShrinkResources = false
        }
        
        debug {
            // ✅ CORRECCIÓN: Sintaxis correcta para Kotlin DSL
            isDebuggable = true
        }
    }
    
    // ✅ CORRECCIÓN: packaging en lugar de packagingOptions para Kotlin DSL
    packaging {
        pickFirst("**/libc++_shared.so")
        pickFirst("**/libjsc.so")
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module"
            )
        }
    }
}

flutter {
    source = "../.."
}