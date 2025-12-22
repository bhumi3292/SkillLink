plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.skill_link"
    compileSdk = flutter.compileSdkVersion

    // You already set this; keep it
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.skill_link"
        minSdk = flutter.minSdkVersion  // must be >= 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
        // Enable Java 8+ API desugaring
        isCoreLibraryDesugaringEnabled = true

        // Use Java 11 compatibility (works with Android Gradle Plugin 8.x)
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring library version 2.1.5 satisfies requirement of flutter_local_notifications >= 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
