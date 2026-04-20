# Play Console — Internal Testing Handoff (v1.0.1+3)

**Handoff Date:** 2026-04-20
**App:** Geo Quiz: Flags, Capitals & Foods
**Package:** com.worldgeo.quiz
**Version:** 1.0.1 (versionCode 3)
**Track:** Internal Testing

---

## 1. Final Artifact Inventory

| Item | Path | Size / Notes |
|---|---|---|
| AAB (release, signed, obfuscated) | `build/app/outputs/bundle/release/app-release.aab` | 59.0 MB (61,860,758 B), arm64-v8a only |
| Debug symbols (for Play crash deobfuscation) | `symbols/app.android-arm64.symbols` | 2.4 MB |
| Upload signing keystore | `android/keystore/geoquiz-upload.jks` | alias `geoquiz`, valid till 2053 |
| Play listing — App icon (512x512) | `store_assets/play_store/icon_512.png` | PNG, no alpha, 512x512 |
| Feature graphic — Default (EN) | `store_assets/play_store/feature_graphic_en_1024x500.png` | 1024x500 |
| Feature graphic — TR override | `store_assets/play_store/feature_graphic_tr_1024x500.png` | 1024x500 |
| Phone screenshots — EN (5) | `store_assets/screenshots/phone/en/` | 01_menu, 02_quiz, 03_result, 04_settings, 05_stats |
| Phone screenshots — TR (5) | `store_assets/screenshots/phone/tr/` | 01_menu, 02_quiz, 03_result, 04_settings, 05_stats |

---

## 2. Upload Steps (Play Console)

1. Play Console → Geo Quiz → **Testing → Internal testing → Create new release**.
2. Upload `app-release.aab`. Play will enroll the app in Play App Signing using the upload cert from `geoquiz-upload.jks`.
3. Under **App bundle → Native debug symbols**, upload `symbols/app.android-arm64.symbols` (zip first if Play requires a `.zip`).
4. Release notes: pull from `release_pack/store/google_play/whatsnew_en.txt` / `whatsnew_tr.txt` (fallback: "Initial internal testing build.").
5. **Store listing → Main store listing (EN-US)** — upload `icon_512.png`, `feature_graphic_en_1024x500.png`, and the 5 EN phone screenshots.
6. **Store listing → Add translation (Turkish tr-TR)** — upload `feature_graphic_tr_1024x500.png` and the 5 TR phone screenshots.
7. Roll out to internal testers list.

---

## 3. Data Safety Form — Product Behavior Summary

| Category | Answer | Evidence |
|---|---|---|
| Does the app collect or share user data? | **No** | No backend, no analytics SDK, no ads SDK. Storage is `shared_preferences` only (on-device). |
| Is data encrypted in transit? | N/A (no user data in transit) | Only outbound traffic is `google_fonts` CDN for Nunito font file. |
| Can users request data deletion? | N/A | Nothing leaves the device; uninstall clears all state. |
| Does the app use a privacy manifest? | iOS: yes (`PrivacyInfo.xcprivacy`). Android: N/A | — |
| Location / contacts / photos / camera / mic access? | **None** | No runtime permissions requested. Only INTERNET in manifest (for fonts). |

Recommended Data Safety answers:
- **Data collected:** None
- **Data shared:** None
- **Security practices:** Data is not collected; nothing to encrypt or delete on request.

---

## 4. Content Rating — Recommended Class

**IARC questionnaire → "Everyone / 3+"**
Reason: educational geography quiz. No violence, no user-generated content, no chat, no ads, no in-app purchases, no location, no profanity. Safe for all ages.

---

## 5. Privacy Policy — STATUS: BLOCKER

- Local markdown drafts exist at `release_pack/legal/privacy_policy_en.md` and `release_pack/legal/privacy_policy_tr.md`.
- **Play Console requires a public HTTPS URL.**
- Contact email unified to `trultruva@gmail.com` across privacy policy, terms, and in-app Settings → Support (AppInfo.supportEmail).
- Host on GitHub Pages / Netlify / personal site before submitting. Internal Testing technically allows a draft URL, but any promotion to Closed/Production track will reject without a live policy.

---

## 6. Internal Testing — Blockers & Non-Blockers

**Blockers (must resolve before INTERNAL testing upload):**
- None. AAB is uploadable as-is.

**Blockers (must resolve before CLOSED/PRODUCTION promotion):**
1. Privacy Policy public URL (see §5).
2. Contact email in privacy policy files.
3. Data Safety form filled (answers prepared in §3).
4. Content rating questionnaire completed (answer from §4).

**Non-blockers / quality TODOs for v1.1:**
- Bundle Nunito font to eliminate runtime Google Fonts download.
- Add Firebase Crashlytics.
- CI/CD pipeline (GitHub Actions).
- 12 missing capital photos (currently placeholders, 6.2% gap).

---

## 7. Verification Receipts

- `flutter analyze` → no issues
- `flutter test` → all tests pass (23/23)
- Icon/splash visually verified on Pixel API 37 emulator (2026-04-20): dark-navy card, gold globe, correct mask rendering, no double-frame artifact.
- Launcher icon adaptive background: `#26282F` (colors.xml + pubspec aligned).
- Icon adaptive XML: bare adaptive-icon (no `<inset>` wrapper) — foreground fills 108dp canvas.

---

## 8. Rollback Plan

If Internal Testing surfaces a regression:
- Previous signed AAB (versionCode 2) is not retained locally. Play Console retains prior release under **Release management → App bundle explorer** — can re-promote from there.
- Source of truth for rollback build: commit `96aca47` (chore: finalize polish, settings, and multilingual release prep).
