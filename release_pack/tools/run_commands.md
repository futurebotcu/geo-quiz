# Build & Release Commands

**Project root:** C:\dev\geo_quiz
**Flutter version requirement:** >=3.5.0

---

## 1. Setup (First Time)

```bash
# Install dependencies
flutter pub get

# Verify Flutter and Dart versions
flutter --version

# Run static analysis (should pass with 0 issues)
flutter analyze

# Run all tests
flutter test
```

---

## 2. Regenerate App Icons

After updating source files in `assets/brand/`:

```bash
# Regenerate launcher icons for Android + iOS
dart run flutter_launcher_icons

# Verify Android outputs:
ls android/app/src/main/res/mipmap-hdpi/
ls android/app/src/main/res/mipmap-xxxhdpi/

# Verify iOS outputs:
ls ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## 3. Regenerate Splash Screen

After updating `assets/brand/splash_logo.png`:

```bash
dart run flutter_native_splash:create

# To remove splash screen (revert to default):
# dart run flutter_native_splash:remove
```

---

## 4. Regenerate Localization Files

After editing `assets/l10n/app_en.arb` or `assets/l10n/app_tr.arb`:

```bash
flutter gen-l10n

# Verify output in lib/l10n/:
ls lib/l10n/
# Should contain: app_localizations.dart, app_localizations_en.dart, app_localizations_tr.dart
```

---

## 5. Android Release Build

### Prerequisites
1. Ensure `android/key.properties` has real (non-placeholder) values:
   ```
   storePassword=YOUR_ACTUAL_PASSWORD
   keyPassword=YOUR_ACTUAL_PASSWORD
   keyAlias=geoquiz
   storeFile=release.keystore
   ```
2. Ensure `android/app/release.keystore` exists locally (never commit to git)

### Build AAB (recommended for Play Store)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Upload this file to Google Play Console
```

### Build APK (for direct distribution / testing)
```bash
flutter build apk --release --split-per-abi

# Outputs:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Verify signing
```bash
# Check APK signature (requires Android SDK build-tools in PATH)
apksigner verify --verbose build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 6. iOS Release Build

### Prerequisites
1. macOS with Xcode installed (latest stable)
2. Apple Developer account with valid certificates
3. Provisioning profile for com.worldgeo.quiz

### Steps
```bash
# Build iOS release (unsigned — Xcode will sign)
flutter build ios --release

# OR open Xcode and archive from there:
open ios/Runner.xcworkspace
# In Xcode: Product → Archive → Distribute App → App Store Connect
```

### IMPORTANT: Add PrivacyInfo.xcprivacy to Xcode target
Before archiving:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Project Navigator → Runner group → right-click → Add Files to "Runner"
3. Select `ios/Runner/PrivacyInfo.xcprivacy`
4. Check "Add to target: Runner"
5. Verify in Build Phases → Copy Bundle Resources → PrivacyInfo.xcprivacy is listed

---

## 7. Version Bumping

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+2
#        ↑ version name (shown to users)
#              ↑ build number (must increment for each store upload)
```

Rules:
- **Android versionCode** = build number (must always increase)
- **iOS CFBundleVersion** = build number (must always increase)
- **versionName / CFBundleShortVersionString** = semantic version

Example for next release:
```yaml
version: 1.0.1+3   # bug fix release
version: 1.1.0+4   # minor feature release
version: 2.0.0+5   # major release
```

---

## 8. Pre-Release Verification Checklist

```bash
# 1. Clean build (catch stale cache issues)
flutter clean && flutter pub get

# 2. Static analysis — must be zero issues
flutter analyze

# 3. Tests — must all pass
flutter test

# 4. Release build succeeds
flutter build appbundle --release

# 5. Check bundle size (rough estimate)
ls -lh build/app/outputs/bundle/release/app-release.aab
```
