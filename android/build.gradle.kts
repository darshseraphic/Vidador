allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // Versions removed here so Gradle inherits 9.0.1 and 2.3.20 from settings.gradle.kts
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    pluginManager.withPlugin("com.android.library") {
        pluginManager.apply("org.jetbrains.kotlin.android")
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}