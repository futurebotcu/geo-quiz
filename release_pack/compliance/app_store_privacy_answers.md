# App Store Connect — Privacy Questionnaire Answers

**App:** Geo Quiz: Flags, Capitals & Foods (com.worldgeo.quiz)
**Bundle ID:** com.worldgeo.quiz
**Category:** Education → Educational Games
**Last reviewed:** February 2026

> Complete these in App Store Connect → App Information → App Privacy

---

## Privacy Policy URL

**REQUIRED.** Enter the URL to your hosted privacy policy.
File: `release_pack/legal/privacy_policy_en.md`

---

## Section: Data Collection

**Do you or your third-party partners collect data from this app?**
→ **No, we do not collect data from this app**

Select this option. This will result in the "No Data Collected" badge on your App Store listing — a strong trust signal for users.

---

## Justification Notes (internal reference)

Why "No data collected" is accurate:

1. **No analytics** — no Firebase Analytics, no Mixpanel, no custom analytics
2. **No crash reporting** — no Crashlytics, no Sentry
3. **No advertising** — no AdMob, no ad SDKs
4. **No account system** — no sign-in, no user profiles
5. **SharedPreferences / NSUserDefaults** — data stored locally on device only;
   Apple does NOT consider on-device local storage as "data collection"
6. **google_fonts** — may download font files; font download requests contain
   no user-identifiable data
7. **INTERNET permission** — present but used only by flutter engine and
   google_fonts; no user data transmitted

---

## App Store Required Reason API Declaration

The app uses **NSUserDefaults** via the `shared_preferences` Flutter plugin.
This is a "Required Reason API" under Apple's policy.

**PrivacyInfo.xcprivacy** has been created at:
`ios/Runner/PrivacyInfo.xcprivacy`

Declared reason: **CA92.1** — "Access info from the same app, per documentation"

> Xcode Action Required: Add PrivacyInfo.xcprivacy to the Runner target in Xcode
> before archiving. See PATCH-2.diff for detailed steps.

---

## Age Rating

**Recommended: 4+**

Rationale:
- No violence, no mature content
- No user-generated content
- No social features, no chat
- No gambling or lotteries
- Educational geography content suitable for all ages

Set in App Store Connect: App Information → Age Rating → answer all questions "None / No" → result: **4+**
