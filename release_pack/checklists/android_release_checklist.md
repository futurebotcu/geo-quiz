# Android Release Checklist

**App:** Geo Quiz: Flags, Capitals & Foods
**Package:** com.worldgeo.quiz
**Target:** Google Play Store

---

## PHASE 1: Pre-Build (Code & Config)

### Secrets & Signing
- [ ] `android/key.properties` has real passwords (NOT placeholder "YOUR_STORE_PASSWORD_HERE")
- [ ] `android/app/release.keystore` exists locally and is backed up securely
- [ ] `key.properties` and `*.keystore` are in `.gitignore` (verified ✅ already)
- [ ] Keystore backup stored in minimum 2 separate secure locations (password manager + cloud)

### Code Quality
- [ ] `flutter analyze` runs with **zero errors** (warnings acceptable if reviewed)
- [ ] `flutter test` — **all tests pass**
- [ ] Debug button confirmed hidden in release: `kDebugMode` guard in `lib/screens/menu_screen.dart:57` ✅ (patched)
- [ ] No hardcoded API keys or secrets in source (verified ✅)

### App Identity
- [ ] `pubspec.yaml` version: check versionName and versionCode are correct
  - versionCode must be HIGHER than any previously uploaded build
  - Current: `1.0.0+2` → next upload minimum: `+3` or higher
- [ ] `android:label` in `strings.xml` = "Geo Quiz" ✅ (patched)
- [ ] `applicationId` = `com.worldgeo.quiz` (DO NOT change)

### Build Config
- [ ] `minSdk = flutter.minSdkVersion` (defaults to 21 = Android 5.0+)
- [ ] `isMinifyEnabled = true` in release buildType ✅
- [ ] `isShrinkResources = true` in release buildType ✅
- [ ] ProGuard rules file exists: `android/app/proguard-rules.pro` ✅

---

## PHASE 2: Build

- [ ] `flutter clean && flutter pub get` (clean build)
- [ ] `flutter gen-l10n` (regenerate localization — use `release_pack/tools/run_commands.md`)
- [ ] `dart run flutter_launcher_icons` (if icons changed)
- [ ] `dart run flutter_native_splash:create` (if splash changed)
- [ ] `flutter build appbundle --release`
- [ ] Build succeeds with NO errors
- [ ] AAB file exists: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Verify signing: `apksigner verify --verbose build/.../app-release.aab`

---

## PHASE 3: Google Play Console Setup

### First-Time Setup (New App Registration)
- [ ] Create app in Google Play Console
- [ ] App name: "Geo Quiz: Flags & Capitals" (from `release_pack/store/google_play/title.txt`)
- [ ] Default language: English (United States)
- [ ] App type: App (not Game — but "Games → Trivia" may work; test both)
- [ ] Category: Education OR Games → Trivia

### Store Listing (EN)
- [ ] Title (EN): from `release_pack/store/google_play/title.txt`
- [ ] Short description (EN): from `release_pack/store/google_play/short_description_en.txt`
- [ ] Full description (EN): from `release_pack/store/google_play/full_description_en.txt`
- [ ] Screenshots (phone): minimum 2, recommended 8 (see `release_pack/design/screenshot_prompt_pack.txt`)
- [ ] Feature graphic: 1024×500 px (see `release_pack/design/store_graphics_spec.md`)
- [ ] App icon: 512×512 px JPG or PNG (generate from `assets/brand/`)

### Store Listing (TR — Additional Language)
- [ ] Add Turkish (Türkçe) language
- [ ] Title (TR): see `release_pack/store/google_play/title.txt` (adapt for TR audience)
- [ ] Short description (TR): from `release_pack/store/google_play/short_description_tr.txt`
- [ ] Full description (TR): from `release_pack/store/google_play/full_description_tr.txt`
- [ ] TR screenshots (optional but recommended)

### Content Rating
- [ ] Complete IARC content rating questionnaire
- [ ] Expected result: Everyone (E) — see `release_pack/compliance/age_rating_notes.md`

### Data Safety
- [ ] Complete Data Safety form: NO data collected (see `release_pack/compliance/google_play_data_safety_answers.md`)
- [ ] Enter Privacy Policy URL (host `release_pack/legal/privacy_policy_en.md` online)

### App Access
- [ ] If app has no login/paywall: select "All or most functionality is available without special access"

---

## PHASE 4: Internal Testing

- [ ] Upload AAB to Internal Testing track
- [ ] Add internal testers (your email + any testers)
- [ ] Download from Play Store and verify:
  - [ ] App installs correctly
  - [ ] App name shows "Geo Quiz" on home screen
  - [ ] All 5 quiz modes work
  - [ ] Turkish language works correctly (ÇÖŞĞÜİ characters)
  - [ ] Quiz results are saved and shown in Stats
  - [ ] Settings persist across app restarts
  - [ ] Debug button is NOT visible in release build
  - [ ] No crashes on startup or during quiz

---

## PHASE 5: Closed / Open Testing → Production

- [ ] Closed Testing: invite external testers (5+ recommended by Google)
- [ ] Address any crash reports or feedback
- [ ] Open Testing (optional): broad beta before production
- [ ] Submit for review → Production
- [ ] Expected review time: 1–3 business days for new apps

---

## REFERENCE FILES
| Step | File |
|------|------|
| Store title | `release_pack/store/google_play/title.txt` |
| Short desc EN | `release_pack/store/google_play/short_description_en.txt` |
| Short desc TR | `release_pack/store/google_play/short_description_tr.txt` |
| Full desc EN | `release_pack/store/google_play/full_description_en.txt` |
| Full desc TR | `release_pack/store/google_play/full_description_tr.txt` |
| Privacy policy | `release_pack/legal/privacy_policy_en.md` |
| Data safety | `release_pack/compliance/google_play_data_safety_answers.md` |
| Age rating | `release_pack/compliance/age_rating_notes.md` |
| Screenshots spec | `release_pack/design/store_graphics_spec.md` |
| Feature graphic | `release_pack/design/feature_graphic_prompt.txt` |
| Build commands | `release_pack/tools/run_commands.md` |
