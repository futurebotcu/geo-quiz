# Google Play Console — Step-by-Step Guide

**App:** Geo Quiz: Flags, Capitals & Foods
**Package:** com.worldgeo.quiz
**Goal:** Internal → Closed Testing → Production

> play.google.com/console

---

## STEP 1: Create New App

1. Go to Google Play Console → All apps → **Create app**
2. App name: `Geo Quiz: Flags & Capitals` (30 chars max — from `release_pack/store/google_play/title.txt`)
3. Default language: **English (United States)**
4. App or game: **App** (alternatively: Game → Trivia)
5. Free or paid: **Free**
6. Accept all declarations → **Create app**

---

## STEP 2: Complete App Setup Dashboard

The dashboard shows tasks to complete. Work through them in order:

### Set up your app

**App access**
- All functionality available without special access

**Ads**
- Does not contain ads

**Content ratings** (IARC Questionnaire)
- Category: Utility / Reference / Education
- Answer all questions → get "Everyone" rating
- Reference: `release_pack/compliance/age_rating_notes.md`

**Target audience and content**
- Age groups that this app targets: 13 and above (or All ages — both work)
- If selecting "under 13": stricter policies apply; select 13+ for simplicity

**News apps**
- Is this a news app? No

**COVID-19 contact tracing**
- Not a COVID contact tracing app

**Data safety**
- Work through the questionnaire using `release_pack/compliance/google_play_data_safety_answers.md`
- Summary: No data collected, users can delete data by clearing app data or uninstalling
- Privacy Policy URL: **MUST BE ENTERED** (host privacy policy before this step)

---

## STEP 3: Store Listing

**Main store listing:**

- App name: copy from `release_pack/store/google_play/title.txt`
- Short description: copy from `release_pack/store/google_play/short_description_en.txt`
- Full description: copy from `release_pack/store/google_play/full_description_en.txt`
- App icon (512×512): generate from `assets/brand/` per `release_pack/design/icon_spec.md`
- Feature graphic (1024×500): create per `release_pack/design/feature_graphic_prompt.txt`
- Phone screenshots (min 2): create per `release_pack/design/screenshot_prompt_pack.txt`

**Add translation (Turkish):**
- Language: Türkçe (Turkish)
- Name: adapt from English title (or use same "Geo Quiz: Flags & Capitals")
- Short description: from `release_pack/store/google_play/short_description_tr.txt`
- Full description: from `release_pack/store/google_play/full_description_tr.txt`

---

## STEP 4: Upload First Build

1. Left menu → **Testing → Internal testing** → Create new release
2. Upload: drag-and-drop `build/app/outputs/bundle/release/app-release.aab`
3. Release name: auto-filled from AAB (e.g. "1.0.0 (2)")
4. Release notes (what's new): copy from `release_pack/store/app_store/what_new_en.txt` (adapt)
5. Review release → **Save and publish**

---

## STEP 5: Internal Testing

1. Internal testing → Testers tab → Create email list
2. Add your Gmail address + any internal testers
3. Copy the opt-in link → testers open link on their Android device → install from Play
4. Test ALL scenarios:
   - All 5 quiz modes
   - Turkish + English language switch
   - Settings persistence
   - Stats screen
   - Correct/incorrect feedback
   - Edge case: very long country names (e.g. "Bosnia and Herzegovina")

---

## STEP 6: Closed Testing (Pre-Launch)

1. Testing → **Closed testing** → Create track (name: "beta")
2. Create new release → upload same or newer AAB
3. Add testers: 5-20 external users (email list or Google Groups)
4. Submit → track goes live after brief review
5. Monitor crash rate and ANR rate in Android vitals

**Google's guidance:** Closed testing with 12+ opt-in testers for 14 days
improves chances of early access to production review.

---

## STEP 7: Open Testing (Optional)

1. Testing → Open testing
2. Upload release → available to any Google Play user who opts in
3. Useful for gathering wider feedback before full production

---

## STEP 8: Production Release

1. Production → Create new release
2. Upload the same AAB (or newer build)
3. Add release notes in all supported languages
4. Rollout percentage: **20%** initially (phased rollout) → increase if no issues
5. **Submit for review** → expect 1–3 business days for new apps

### Review Notes (what Google checks):
- Store listing accuracy (screenshots match actual app)
- Privacy policy accessible and accurate
- Data safety answers match actual app behavior
- Content rating matches app content
- No policy violations (ads, impersonation, malware, etc.)

---

## POST-LAUNCH

- Monitor: Android Vitals → Crash rate, ANR rate (<1% crash-free target)
- Monitor: Reviews and ratings → respond to all reviews promptly
- Version updates: increment versionCode each time, update release notes
- Data safety: update if you add analytics or change data practices

---

## TIMELINE ESTIMATE

| Phase | Duration |
|-------|---------|
| App setup + store listing | 2-4 hours |
| Build + upload | 30 min |
| Internal testing | 1-3 days |
| Closed testing (if required) | 7-14 days |
| Production review | 1-3 business days |
| **Total (optimistic)** | **1 week** |
| **Total (typical)** | **2-3 weeks** |
