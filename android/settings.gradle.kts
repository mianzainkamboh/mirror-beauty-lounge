pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
       
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
}

include(":app")
