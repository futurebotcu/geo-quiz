# Google Play — Data Safety Form Answers

**App:** Geo Quiz: Flags, Capitals & Foods (com.worldgeo.quiz)
**Category:** Education
**Last reviewed:** February 2026

> Complete these answers in Google Play Console → App content → Data safety

---

## Section 1: Data Collection and Sharing

**Does your app collect or share any of the required user data types?**
→ **NO**

The app does not collect, transmit, or share user data with any external party.

---

## Section 2: Data Practices (if NO above, mark all below as NO)

| Question | Answer |
|----------|--------|
| Does your app share user data with third parties? | **No** |
| Does your app collect user data? | **No** |

---

## Section 3: Security Practices

| Practice | Answer |
|----------|--------|
| Is your data encrypted in transit? | **N/A** (no data transmitted) |
| Do you provide a way for users to request data deletion? | **Yes** — via Settings → Clear All Data, or by uninstalling the app |

---

## Section 4: Data Types (all should be "Not collected")

Since the app collects no data, for EVERY data type in the form select:
- **"Data is not collected"**

This applies to ALL categories:
- Location ❌ not collected
- Personal info ❌ not collected
- Financial info ❌ not collected
- Health & fitness ❌ not collected
- Messages ❌ not collected
- Photos & videos ❌ not collected
- Audio files ❌ not collected
- Files & docs ❌ not collected
- Calendar ❌ not collected
- Contacts ❌ not collected
- App activity ❌ not collected
- Web browsing ❌ not collected
- App info & performance ❌ not collected (no crash reporting)
- Device or other IDs ❌ not collected

---

## Notes for Reviewer

- `shared_preferences` stores data LOCALLY on device only; this is not "data collection" in the Play Store sense (data never leaves the device)
- `google_fonts` may make a network request to download font files; no user data is attached to this request
- INTERNET permission is required by the google_fonts package; the app itself makes no API calls
- No analytics SDK, no crash reporting SDK, no advertising SDK

---

## Privacy Policy URL

You MUST enter a privacy policy URL in the Data Safety form.
Use the hosted version of: `release_pack/legal/privacy_policy_en.md`

Suggested hosting options:
- GitHub Pages (free): https://yourusername.github.io/geo-quiz-privacy
- GitHub raw file (less ideal, no SSL guarantee): raw.githubusercontent.com/...
- Simple webpage on your domain
