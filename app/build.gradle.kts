import com.vdreamers.version.AppBuildConfigs
import com.vdreamers.version.Deps
import org.jetbrains.kotlin.konan.properties.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
}

var keystorePWD = ""
var keystoreAlias = ""
var keystoreAliasPWD = ""
// local.properties file in the root director
var keyFile = project.rootProject.file("local.properties")

val properties = Properties()
// local.properties exists
if (keyFile.exists()) {
    properties.load(keyFile.inputStream())
} else {
    keyFile = file("../no_exists_keystore.tmp")
}

// local.properties contains keystore.path
if (properties.containsKey("keystore.path")) {
    keyFile = file(properties.getProperty("keystore.path"))
    keystorePWD = properties.getProperty("keystore.password")
    keystoreAlias = properties.getProperty("keystore.alias")
    keystoreAliasPWD = properties.getProperty("keystore.alias_password")
} else {
    keyFile = file("../no_exists_keystore.tmp")
}

val isRunningOnTravis = System.getenv("CI") == "true"
if (isRunningOnTravis) {
    keyFile = file("../mrd@vdreamers")
    keystorePWD = System.getenv("KEYSTORE_PWD")
    keystoreAlias = System.getenv("KEYSTORE_ALIAS")
    keystoreAliasPWD = System.getenv("KEYSTORE_ALIAS_PWD")
}

android {
    compileSdkVersion(AppBuildConfigs.COMPILE_SDK_VERSION)
    buildToolsVersion(AppBuildConfigs.BUILD_TOOLS_VERSION)

    defaultConfig {
        applicationId(AppBuildConfigs.APPLICATION_ID)
        minSdkVersion(AppBuildConfigs.MIN_SDK_VERSION)
        targetSdkVersion(AppBuildConfigs.TARGET_SDK_VERSION)
        versionCode(AppBuildConfigs.VERSION_CODE)
        versionName(AppBuildConfigs.VERSION_NAME)

        testInstrumentationRunner("androidx.test.runner.AndroidJUnitRunner")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreAlias
            keyPassword = keystoreAliasPWD
            storeFile = keyFile
            storePassword = keystorePWD
        }
    }

    buildTypes {
        val debug = getByName("debug")
        debug.apply {
            minifyEnabled(false)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        val release = getByName("release")
        release.apply {
            minifyEnabled(false)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (keyFile.exists() || isRunningOnTravis) {
                println("WITH -> buildTypes -> release: using jks key")
                signingConfig = signingConfigs.getByName("release")
            } else {
                println("WITH -> buildTypes -> release: using default key")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
    compileOptions {
        sourceCompatibility(JavaVersion.VERSION_1_8)
        targetCompatibility(JavaVersion.VERSION_1_8)
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation(Deps.Kotlin.stdlib())
    implementation(Deps.AndroidX.coreKtx())
    implementation(Deps.AndroidX.appcompat())
    implementation(Deps.AndroidX.constraintLayout())
    implementation(Deps.Google.material())

    testImplementation(Deps.Test.junit())
    androidTestImplementation(Deps.AndroidTest.junit())
    androidTestImplementation(Deps.AndroidTest.espressoCore())
}