# App Store Connect — Step-by-Step Guide

**App:** Geo Quiz: Flags, Capitals & Foods
**Bundle ID:** com.worldgeo.quiz
**Goal:** TestFlight Internal → App Store Review → Production

> appstoreconnect.apple.com | Requires: Apple Developer account ($99/yr)

---

## STEP 1: Apple Developer Setup (One-Time)

1. Join Apple Developer Program at developer.apple.com ($99/year)
2. Create App ID in Developer portal:
   - Certificates, IDs & Profiles → Identifiers → + (New)
   - Type: App IDs → App
   - Bundle ID: `com.worldgeo.quiz` (Explicit)
   - Capabilities: none required for this app
3. Create Distribution Certificate:
   - Certificates → + → Apple Distribution
   - Generate CSR from Keychain Access → upload → download
4. Create App Store Provisioning Profile:
   - Profiles → + → App Store Connect
   - Select App ID: com.worldgeo.quiz
   - Select certificate → name it "Geo Quiz AppStore"
   - Download and double-click to install in Xcode

---

## STEP 2: Create App in App Store Connect

1. Go to appstoreconnect.apple.com → My Apps → +  → New App
2. Fill in:
   - Platforms: **iOS**
   - Name: `Geo Quiz: Flags & Capitals` (from `release_pack/store/app_store/name.txt`)
   - Primary Language: **English (U.S.)**
   - Bundle ID: `com.worldgeo.quiz`
   - SKU: `geo-quiz-001` (any unique alphanumeric)
   - User Access: Full Access
3. Click **Create**

---

## STEP 3: App Information

Left menu → App Information:

- **Category:** Education (Primary) | Reference (Secondary) — or Games > Trivia
- **Content Rights:** "This app does not contain, display, or use third-party content"
  (ASSUMPTION: verify food photos are original/licensed; capital photos should be credited)
- **Age Rating:** Click Edit → complete questionnaire → result: **4+**
  - All answers "None" or "No" per `release_pack/compliance/age_rating_notes.md`
- **Privacy Policy URL:** Enter the URL to your hosted privacy policy
  (host `release_pack/legal/privacy_policy_en.md` before this step)

---

## STEP 4: Pricing and Availability

- Price: **Free**
- Availability: select all countries (or start with Turkey + USA + UK)
- Pre-order: No (for first release)

---

## STEP 5: App Privacy (Data Practices)

Left menu → App Privacy:

- Click **Get Started**
- "Do you collect data from this app?" → **No, we do not collect data**
- Click **Publish**
- This results in the "No Data Collected" privacy label — a positive trust signal

Reference: `release_pack/compliance/app_store_privacy_answers.md`

---

## STEP 6: Prepare Version 1.0 Store Listing

Left menu → 1.0 Prepare for Submission:

### Screenshots (REQUIRED before submission)
Upload per `release_pack/design/store_graphics_spec.md`:
- [ ] iPhone 6.9" screenshots (1320×2868)
- [ ] iPhone 6.7" screenshots (1290×2796)
- [ ] iPhone 5.5" screenshots (1242×2208)
- [ ] iPad 13" screenshots (2064×2752) — if supporting iPad

### App Information Fields
- **Name:** from `release_pack/store/app_store/name.txt`
- **Subtitle:** from `release_pack/store/app_store/subtitle_en.txt`
- **Description:** use adapted content from `release_pack/store/google_play/full_description_en.txt`
  (remove emoji bullets if App Store reviewer flags them; plain text is safer)
- **Keywords:** from `release_pack/store/app_store/keywords_en.txt`
- **Support URL:** your website or GitHub repo
- **What's New:** from `release_pack/store/app_store/what_new_en.txt`

### Add Turkish Localization
- Click language selector → Add Turkish
- Subtitle: from `release_pack/store/app_store/subtitle_tr.txt`
- Keywords: from `release_pack/store/app_store/keywords_tr.txt`
- What's New: from `release_pack/store/app_store/what_new_tr.txt`
- Description: translate or adapt full description

### Build
- This section requires a build to be uploaded first (see Step 7)
- Select the uploaded build from TestFlight

### Review Information
- Sign-in required: **No**
- Notes: "Offline geography quiz app. No login required. Works fully offline.
  Available in English and Turkish. All content bundled in the app."
- Contact info: your name, phone, email

---

## STEP 7: Build & Upload

### Build in Xcode

**Before archiving — CRITICAL:**
- [ ] PrivacyInfo.xcprivacy is added to Runner target (see PATCH-2.diff)
- [ ] Bundle ID is `com.worldgeo.quiz` in Xcode project settings
- [ ] Version matches pubspec.yaml (e.g. 1.0.0 / build 2)

```bash
# In project root:
flutter build ios --release

# Then in Xcode:
# Select: Any iOS Device (arm64) as destination
# Product → Archive
# Xcode Organizer opens automatically
```

### Distribute from Organizer
1. Select archive → **Distribute App**
2. Method: **App Store Connect**
3. Options: Upload
4. Review entitlements and certificates
5. **Upload** (may take 5-10 minutes)

### Verify Upload
- App Store Connect → TestFlight → wait for processing (up to 30 min)
- Look for any ITMS-9xxxx errors in email from Apple:
  - **ITMS-91053** (No Privacy Manifest) → Fixed by PATCH-2 if PrivacyInfo.xcprivacy is added to Xcode target
  - If no errors: proceed

---

## STEP 8: TestFlight — Internal Testing

1. TestFlight → Internal Testing → App Store Connect Users
2. Add your Apple ID (requires Apple Developer membership)
3. Build appears automatically after processing
4. Install on iPhone via TestFlight app
5. Test all functionality per the iOS checklist

---

## STEP 9: TestFlight — External Testing (Optional)

1. TestFlight → External Groups → + → Create group "Public Beta"
2. Add build → **Submit for Review** (Apple reviews TestFlight external builds)
3. Review typically 1-2 days
4. After approval: share opt-in link (or public link) with testers

---

## STEP 10: Submit for App Store Review

1. Back to 1.0 Prepare for Submission
2. Attach the TestFlight build to the submission
3. Complete all required sections (red dots should be gone)
4. Click **Submit for Review** at the top right
5. Confirm phased release settings if desired

### Review Timeline
| Scenario | Time |
|----------|------|
| Typical first submission | 1-2 business days |
| Peak periods (holidays) | 3-5 business days |
| Rejection → fix → resubmit | Add 1-2 days per cycle |

### Common Rejection Reasons (and how this app avoids them):
| Reason | Status |
|--------|--------|
| Missing Privacy Policy | Host privacy policy BEFORE submitting |
| Privacy Manifest missing | Fixed by PATCH-2 |
| Screenshots don't match app | Use real screenshots from app |
| Metadata has misleading claims | Store text accurately describes actual features |
| App crashes on review device | Test on physical device before submitting |

---

## POST-LAUNCH

- Monitor crash logs in Xcode Organizer → Crashes
- Respond to App Store reviews (App Store Connect → Ratings and Reviews)
- Submit updates: increment CFBundleVersion (build number) for every upload
- Plan for App Store policy changes (Apple updates policies annually)

---

## TIMELINE ESTIMATE

| Phase | Duration |
|-------|---------|
| Apple Developer setup | 1-2 hours (first time) |
| App Store Connect app setup | 1-2 hours |
| Build + upload | 30-60 min |
| TestFlight internal testing | 1-3 days |
| App Store review | 1-3 business days |
| **Total (optimistic)** | **3-5 business days** |
| **Total (with revisions)** | **1-2 weeks** |
