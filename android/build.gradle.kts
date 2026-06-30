allprojects {
    repositories {
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        maven { url = uri("https://mirrors.huaweicloud.com/repository/maven/") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://repo1.maven.org/maven2/") }
        google()
        mavenCentral()
    }
}

// Global dependency resolution strategy to exclude old Android Support Library
subprojects {
    configurations.all {
        resolutionStrategy {
            // Force use of AndroidX instead of old Support Library
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")

            // Exclude all old Android Support Library modules
            eachDependency {
                if (requested.group == "com.android.support") {
                    useTarget("androidx.${requested.name}:${requested.version}")
                }
            }

            // Explicitly exclude old Support Library
            exclude(group = "com.android.support", module = "support-compat")
            exclude(group = "com.android.support", module = "support-core-utils")
            exclude(group = "com.android.support", module = "support-core-ui")
            exclude(group = "com.android.support", module = "support-fragment")
            exclude(group = "com.android.support", module = "support-media-compat")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
