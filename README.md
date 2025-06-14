# 💳 Card Nudge - Credit Card Manager

<div align="center">
  <img src="https://github.com/ASHWINI-GUPTA/Card-Nudge/blob/main/assets/icons/icon.png" alt="Card Nudge App Icon" height="150">
</div>

Stay ahead of your credit card dues - gently. A modern, minimal Flutter app to manage all your credit cards in one place.

## 🌟 Features

### 🏦 Card Management
- ➕ Add multiple credit cards with details
- 🏷️ Custom names, bank info, last 4 digits
- 📅 Track billing cycles & due dates
- 💰 Set card limits for better control

### 🔔 Smart Reminders
- ⏰ Local notifications 3 days before due date
- 🔔 Due day reminders
- 🎯 Never miss a payment deadline

### 📊 Dashboard & Views
- 📆 Visual calendar view of due dates
- 📝 Clean list view of all cards
- 🚨 Color-coded status (upcoming, near-due, overdue)
- 📈 Total dues summary

### 🛡️ Data Security
- 📱 Offline-first design
- 🔄 Cloud Sync functionality


## 🛠️ Technology Stack

```plaintext
Flutter 3.19+ • Dart 3.x
├── Hive (Local Database)
├── Local Notifications
├── Material 3 Design
├── Dark/Light Theme
└── Platform: Android & iOS

### Steps to Run the App

1. **Clone the Repository**:
  ```bash
# Clone the Card Nudge repository from GitHub
git clone https://github.com/ASHWINI-GUPTA/Card-Nudge.git
cd Card-Nudge
  ```

2. **Install Dependencies**:
  Ensure you have Flutter installed. Then, run:
  ```bash
# Install required packages
flutter pub get
# Generate necessary files
flutter packages pub run build_runner build --delete-conflicting-outputs 
# Generate localization files
flutter gen-l10n
  ```

3. **Set Up Environment Variables**:
  Create a `.env` file in the root directory with the following content:
  ```env
SUPABASE_URL=https://{ACCOUNT}.supabase.co
SUPABASE_ANON_KEY={ANON_KEY}

GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=....googleusercontent.com
  ```
> Replace {ACCOUNT} with your Supabase project ID and {ANON_KEY} with your anonymous key from Supabase dashboard for cloud sync and Login to Work

> Google OAuth client IDs for authentication, Replace with your Google OAuth client IDs from Google Cloud Console

4. **Run the App**:
  For Android:
  ```bash
# Launch the app on an Android emulator or device
flutter run
  ```
  For iOS:
  ```bash
# Launch the app on an iOS simulator or device
flutter run -d ios
  ```

5. **Build using Script**:

```pwsh
# Run the PowerShell script to build the app bundle or APK in release or debug mode
. .\build_apk.ps1

Build-CardNudgeApp -Format appbundle -Profile release
```
