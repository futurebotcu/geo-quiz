# iOS Release Checklist

**App:** Geo Quiz: Flags, Capitals & Foods
**Bundle ID:** com.worldgeo.quiz
**Target:** Apple App Store

> Requires: macOS + Xcode (latest stable) + active Apple Developer account ($99/year)

---

## PHASE 1: Pre-Build (Code & Config)

### Info.plist Verification
- [ ] `CFBundleDisplayName` = "Geo Quiz" ✅ (patched)
- [ ] `CFBundleName` = "Geo Quiz" ✅ (patched)
- [ ] `CFBundleIdentifier` = `$(PRODUCT_BUNDLE_IDENTIFIER)` (set in Xcode project settings)
- [ ] `CFBundleShortVersionString` = `$(FLUTTER_BUILD_NAME)` → reads from pubspec.yaml version
- [ ] `CFBundleVersion` = `$(FLUTTER_BUILD_NUMBER)` → reads from pubspec.yaml build number
- [ ] Orientations declared correctly (portrait + landscape for iPhone + iPad) ✅
- [ ] `CADisableMinimumFrameDurationOnPhone` = true ✅ (ProMotion display support)

### Privacy Manifest (BLOCKER — required for App Store upload)
- [ ] `ios/Runner/PrivacyInfo.xcprivacy` file exists ✅ (patched — file created)
- [ ] **Xcode step:** Open `ios/Runner.xcworkspace` → Add `PrivacyInfo.xcprivacy` to Runner target
  - Project Navigator → Runner group → right-click → Add Files to "Runner"
  - Check "Add to target: Runner"
  - Verify in Build Phases → Copy Bundle Resources
- [ ] Declared reason: `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1` ✅

### App Transport Security (ATS)
- [ ] No ATS exceptions needed (app is offline, no HTTP calls)
- [ ] If ATS exception is added in future, document the reason

### Entitlements
- [ ] Check `ios/Runner/Runner.entitlements` — no extra entitlements needed for this app
  - No push notifications
  - No iCloud
  - No Sign in with Apple
  - No in-app purchases
  - No associated domains

### Code Quality
- [ ] `flutter analyze` — zero errors
- [ ] `flutter test` — all pass
- [ ] `flutter build ios --release` — succeeds locally

---

## PHASE 2: Xcode Setup (One-Time)

- [ ] Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
- [ ] Runner target → Signing & Capabilities:
  - [ ] Team: select your Apple Developer account
  - [ ] Bundle Identifier: `com.worldgeo.quiz`
  - [ ] Provisioning Profile: Xcode Managed (Automatic) OR manual App Store profile
- [ ] Deployment Target: iOS 12.0 or higher (Flutter default is fine)
- [ ] Verify "Automatically manage signing" is checked (or manual profile selected)
- [ ] Build the project in Xcode once to verify no errors

---

## PHASE 3: App Store Connect Setup (First-Time)

### Create the App Record
- [ ] Go to appstoreconnect.apple.com
- [ ] My Apps → + → New App
  - Platforms: iOS
  - Name: "Geo Quiz: Flags & Capitals" (from `release_pack/store/app_store/name.txt`)
  - Primary language: English
  - Bundle ID: `com.worldgeo.quiz` (must match Xcode)
  - SKU: `geo-quiz-001` (any unique string)
  - User access: Full access (for now)

### App Information
- [ ] Category: Primary → Education (or Games → Trivia)
- [ ] Content Rights: Do not use third-party content (all content is original/licensed)
- [ ] Age Rating: Complete questionnaire → expect **4+** (see `release_pack/compliance/age_rating_notes.md`)
- [ ] Privacy Policy URL: (host `release_pack/legal/privacy_policy_en.md` online first)

### Version Information (1.0 Prepare for Submission)
- [ ] App name: from `release_pack/store/app_store/name.txt`
- [ ] Subtitle (EN): from `release_pack/store/app_store/subtitle_en.txt`
- [ ] Description (EN): use content from `release_pack/store/google_play/full_description_en.txt` (adapt as needed)
- [ ] Keywords (EN): from `release_pack/store/app_store/keywords_en.txt`
- [ ] What's New: from `release_pack/store/app_store/what_new_en.txt`
- [ ] Support URL: (your website or GitHub repo URL)
- [ ] Marketing URL: (optional)

### Localizations (TR)
- [ ] Add Turkish localization in App Store Connect
- [ ] Subtitle (TR): from `release_pack/store/app_store/subtitle_tr.txt`
- [ ] Keywords (TR): from `release_pack/store/app_store/keywords_tr.txt`
- [ ] What's New (TR): from `release_pack/store/app_store/what_new_tr.txt`

---

## PHASE 4: Build & Upload

### Archive in Xcode
```bash
# Option A: Command line
flutter build ios --release
# Then open Xcode and: Product → Archive

# Option B: Direct from Xcode
# Open Runner.xcworkspace → select "Any iOS Device (arm64)" → Product → Archive
```

- [ ] Archive succeeds with no errors or warnings about privacy manifest
- [ ] Xcode Organizer → distribute → App Store Connect → upload

### Verify Upload
- [ ] Build appears in App Store Connect → TestFlight
- [ ] No ITMS-9xxxx errors in upload
  - ITMS-91053 (Privacy Manifest) — should be resolved by PATCH-2
- [ ] Processing completes (5-30 minutes)

---

## PHASE 5: TestFlight → Review

- [ ] Internal Testing:
  - Add internal testers (up to 25 Apple IDs)
  - Install and verify on real iPhone + iPad
  - Test all 5 quiz modes
  - Verify Turkish characters (ÇÖŞĞÜİ) render correctly
  - Verify app name shows "Geo Quiz" under icon
  - Verify no debug button visible

- [ ] External TestFlight (optional):
  - Apple review required for external TestFlight (1-2 days)

### App Store Review Submission
- [ ] Screenshots uploaded for all required sizes (see `release_pack/design/store_graphics_spec.md`)
- [ ] App previews (video) — optional
- [ ] App Review Information:
  - Sign-in required: **No** (no login)
  - Notes for reviewer: "Offline geography quiz app. All content is bundled. No account required to test. Available in English and Turkish."
- [ ] Phased release: optional (recommended for first release)
- [ ] Submit for Review

---

## REFERENCE FILES
| Step | File |
|------|------|
| App Store name | `release_pack/store/app_store/name.txt` |
| Subtitle EN | `release_pack/store/app_store/subtitle_en.txt` |
| Subtitle TR | `release_pack/store/app_store/subtitle_tr.txt` |
| Keywords EN | `release_pack/store/app_store/keywords_en.txt` |
| Keywords TR | `release_pack/store/app_store/keywords_tr.txt` |
| What's New EN | `release_pack/store/app_store/what_new_en.txt` |
| What's New TR | `release_pack/store/app_store/what_new_tr.txt` |
| Privacy manifest | `ios/Runner/PrivacyInfo.xcprivacy` |
| Privacy policy | `release_pack/legal/privacy_policy_en.md` |
| App Store privacy | `release_pack/compliance/app_store_privacy_answers.md` |
| Age rating | `release_pack/compliance/age_rating_notes.md` |
| Screenshots spec | `release_pack/design/store_graphics_spec.md` |
| Build commands | `release_pack/tools/run_commands.md` |
