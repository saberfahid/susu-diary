# 🚀 Susu Diary — Google Play Store Upload Guide

## Step 1: Download the Signed AAB

1. Go to: https://github.com/saberfahid/susu-diary/actions/runs/21808670205
2. Scroll to the **Artifacts** section at the bottom
3. Download **release-aab** (this contains `app-release.aab`)
4. Extract the ZIP to get `app-release.aab`

---

## Step 2: Create a Google Play Developer Account

If you don't have one yet:
1. Go to https://play.google.com/console
2. Sign in with your Google account
3. Pay the **one-time $25 registration fee**
4. Complete identity verification (may take 1-2 days)

---

## Step 3: Create the App in Play Console

1. Go to **Play Console** → click **"Create app"**
2. Fill in:
   - **App name**: `Susu — Your AI Diary`
   - **Default language**: English (United States)
   - **App or Game**: App
   - **Free or Paid**: Free
3. Accept declarations & click **"Create app"**

---

## Step 4: Set Up Store Listing

Go to **Main store listing** and fill in:

### App Details
- **App name**: `Susu — Your AI Diary`
- **Short description** (max 80 chars):
  ```
  AI-powered personal diary with voice entries, smart insights, PIN lock & more 🤖
  ```
- **Full description**: Copy from `store_listing/PLAY_STORE_LISTING.md`

### Graphics
- **App icon** (512x512): Upload `store_listing/hi_res_icon_512.png`
- **Feature graphic** (1024x500): Upload `store_listing/feature_graphic.png`
- **Screenshots**: Take 4-8 screenshots from your phone showing:
  - Home page with entries
  - Writing a new entry
  - Voice recording
  - Settings / Dark mode
  - PIN lock screen

### Categorization
- **App category**: Productivity (or Lifestyle)
- **Tags**: diary, journal, personal diary

---

## Step 5: Content Rating

1. Go to **Policy** → **App content** → **Content rating**
2. Start the questionnaire
3. Answer honestly (Susu has no violence, gambling, etc.)
4. You'll likely get **Everyone** rating

---

## Step 6: Privacy Policy

1. Go to **Policy** → **App content** → **Privacy policy**
2. Enter URL: `https://saberfahid.github.io/susu-diary/privacy.html`

---

## Step 7: Target Audience & Ads

1. Go to **Policy** → **App content** → **Target audience**
2. Select age group: **18 and over** (simplest, avoids COPPA)
3. **Ads**: Select "No, my app does not contain ads"

---

## Step 8: Data Safety

1. Go to **Policy** → **App content** → **Data safety**
2. Does your app collect or share data? → **No**
   - Susu stores everything locally, no cloud sync, no analytics
3. Complete the form — most answers will be "No"

---

## Step 9: Upload the AAB

1. Go to **Release** → **Production** (or start with **Internal testing**)
2. Click **"Create new release"**
3. Upload `app-release.aab`
4. Release name: `1.0.3 (4)`
5. Release notes:
   ```
   🌸 Susu Diary v1.0.3

   ✨ What's new:
   • Voice diary entries — tap the mic to record your thoughts
   • Voice entries now appear on your home page
   • Cute custom notification sound 🔔
   • Notifications persist after closing the app
   • In-app Privacy Policy & Terms of Service
   • Forgot PIN — reset with biometrics

   🐛 Bug fixes:
   • Fixed notification timezone handling
   • Fixed biometric authentication flow
   • Improved app icon scaling
   ```
6. Click **"Review release"** → **"Start rollout"**

---

## Step 10: Review & Publish

- Google reviews new apps (usually takes **1-7 days**)
- You'll get an email when approved
- Your app will be live on the Play Store! 🎉

---

## Important Notes

⚠️ **BACKUP YOUR KEYSTORE!**
- File: `android/susu-release-key.jks`
- Password: `SusuDiary2026!`
- Alias: `susu`
- **If you lose this keystore, you can NEVER update your app on Play Store!**
- Save copies on a USB drive, cloud storage, or somewhere safe.

⚠️ **For Future Updates:**
1. Update `version` in `pubspec.yaml` (e.g., `1.0.4+5`)
2. Push to GitHub → CI builds signed AAB automatically
3. Download AAB from GitHub Actions artifacts
4. Upload to Play Console → Create new release

---

## Quick Testing Tip
Before going to Production, you can use **Internal testing** track first:
1. Go to **Release** → **Testing** → **Internal testing**
2. Create a testers list (add your email)
3. Upload AAB there first
4. Test the signed build from Play Store
5. When satisfied, promote to Production
