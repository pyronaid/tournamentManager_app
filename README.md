# tournamentmanager

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



## Instruction for Android build
- If you have some trouble start from a fresh config. Backup the old android folder. Remove it. Recreate it using the command 'flutter create .' 
- See the current flutter configuration using 'flutter doctor -v'
  [√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
  • Android SDK at C:\Users\pyroe\AppData\Local\Android\sdk
  • Platform android-34, build-tools 34.0.0
  • Java binary at: C:\Dev\tool\Android Studio\jbr\bin\java
  • Java version OpenJDK Runtime Environment (build 21.0.3+-12282718-b509.11)
  • All Android licenses accepted.
- Double check the compatibility matrix at this link
  https://docs.gradle.org/current/userguide/compatibility.html#java 
  I have for example the JAVA VERSION: 21 and this require minimum gradle version 8.5 but in wrapper is present 8.3
- Add to android/build.gradle the following code to prevent issue related to namespace
  allprojects {
    repositories {
      google()
        mavenCentral()
      }

    subprojects {
      afterEvaluate { project ->
        if (project.hasProperty('android')) {
          project.android {
            if (namespace == null) {
              namespace project.group
            }
          }
        }
      }
    }
  }
- Execute on android folder the upgrade of gradle version following what described in the matrix
  ./gradlew wrapper --gradle-version 8.5
- To change the flutter variables you have to open
  Starting August 31, 2023, all apps (except for Wear OS) must target Android 13 (API level 33) or higher in order to be submitted to Google Play for review and remain discoverable by all Google Play users.
  <flutter_dir>/flutter/packages/flutter_tools/gradle/src/main/groovy/flutter.groovy
  public  final int minSdkVersion = 33
  public final int compileSdkVersion = 34
  public final int targetSdkVersion = 34
  public final String ndkVersion = "27.0.12077973"
  public String flutterVersionCode = null
  public String flutterVersionName = null
- Open the android folder and launch the tools > AGP upgrade assistant
- Use the https://developer.android.com/build/kotlin-support?hl=it to check which version is compatible with kotlin version
  id "org.jetbrains.kotlin.android" version "1.9.20" apply false
  in android/settings.gradle
- Rebuild using this new config (use before this command if you do multiple attempts ./gradlew clean )
  ./gradlew build 
