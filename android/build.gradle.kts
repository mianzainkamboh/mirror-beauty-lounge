buildscript {
    repositories {
        google()
        mavenCentral()
    }
    
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()


subprojects {
    project.evaluationDependsOn(":app")
}


   

