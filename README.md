# OPing

Android app that sends a local notification whenever a new One Piece manga chapter drops on MangaDex — no backend, no Firebase, completely free.

## Features

- Polls MangaDex once per hour in the background via WorkManager
- Local push notification on new chapter detection
- Home screen shows the latest chapter with a direct MangaDex link
- "Check Now" button for instant manual checks
- Toggle to pause/resume background polling
- Zero cost: no server, no cloud functions, no subscriptions

## Architecture

```
App launch
  ├── NotificationService.initialize()
  └── Workmanager.registerPeriodicTask() — hourly background job

Background isolate (every ~1 hour)
  └── WorkerTask.execute()
        ├── MangaDexService.fetchLatestChapter()
        ├── ChapterStorageService.getLastSeenChapter()
        └── if newer → show notification + save chapter number
```

**Data source:** MangaDex public API — no authentication required.

## Requirements

- Android 8.0+ (API 26+)
- Internet connection for chapter checks

## Setup (development)

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install/linux) (stable channel)
- Android SDK with platform-tools and `platforms;android-34`
- JDK 17+

```bash
# Add to ~/.zshrc
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$HOME/development/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

### Run

```bash
git clone https://github.com/guilhermeleitao2002/OPing.git
cd OPing
flutter pub get
flutter run          # debug on connected device
```

### Test

```bash
flutter test                        # unit tests (18 tests, no device needed)
flutter test integration_test/      # integration tests (requires connected device)
```

### Release build

```bash
# Requires android/key.properties and android/app/oping-release.jks (not in repo)
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## Project structure

```
lib/
├── main.dart                        # app entry point, WorkManager init
├── models/chapter.dart              # Chapter data class + MangaDex parser
├── services/
│   ├── manga_dex_service.dart       # MangaDex HTTP client
│   ├── chapter_storage_service.dart # SharedPreferences wrapper
│   └── notification_service.dart   # local notification channel
├── workers/chapter_check_worker.dart# WorkManager callback + orchestration
├── screens/home_screen.dart         # main UI
└── widgets/chapter_card.dart        # chapter display card
```

## Signing

The keystore and `android/key.properties` are excluded from the repo. To sign your own build:

```bash
keytool -genkeypair -alias oping -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore android/app/oping-release.jks \
  -dname "CN=Your Name, O=YourOrg, C=US" \
  -storepass <password> -keypass <password>
```

Then create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=oping
storeFile=oping-release.jks
```
