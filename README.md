# 💳 Card Nudge - Credit Card Manager

<div align="center">
  <img src="https://github.com/ASHWINI-GUPTA/Card-Nudge/blob/main/assets/icons/icon.png" alt="Card Nudge App Icon" height="150">
</div>

**Stay ahead of your credit card dues – gently.**  
A modern, minimal Flutter app to manage all your credit cards in one place.

---

## 🚀 Features

### 🏦 Card Management
- Add multiple credit cards with custom names, bank info, and last 4 digits
- Track billing cycles & due dates
- Set card limits for better control

### 🔔 Smart Reminders
- Local notifications 3 days before due date and on due day
- Daily insight notification at your preferred time
- Never miss a payment deadline

### 📊 Dashboard & Views
- Visual calendar and list view of due dates
- Color-coded status (upcoming, near-due, overdue)
- Total dues summary and utilization insights

### 🛡️ Data Security & Sync
- Offline-first design with Hive local database
- Cloud sync with Supabase (secure, privacy-first)
- Google/GitHub OAuth login

### 🌗 Modern UI
- Material 3 Design
- Dark/Light theme support
- Responsive and accessible

---

## 🛠️ Technology Stack

- **Flutter 3.19+** / **Dart 3.x**
- Hive (Local Database)
- Supabase (Cloud Sync & Auth)
- flutter_local_notifications (Reminders)
- Riverpod (State Management)
- GoRouter (Navigation)
- Material 3

---

## 📲 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ASHWINI-GUPTA/Card-Nudge.git
cd Card-Nudge
```

### 2. Install Dependencies

```bash
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### 3. Set Up Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=https://{ACCOUNT}.supabase.co
SUPABASE_ANON_KEY={ANON_KEY}
GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=....apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=....googleusercontent.com
```
- Replace `{ACCOUNT}` and `{ANON_KEY}` with your Supabase project credentials.
- Replace Google OAuth client IDs with your values from Google Cloud Console.

### 4. Run the App

For Android:
```bash
flutter run
```
For iOS:
```bash
flutter run -d ios
```

### 5. Build Using Script (Optional)

```pwsh
. .\build_android.ps1
Build-CardNudgeApp -Format appbundle -Profile release
```

---

## 📝 Project Structure

```
lib/
  ├── data/           # Hive models, adapters, storage
  ├── presentation/   # Screens, widgets, providers
  ├── services/       # Notification, sync, navigation, supabase
  ├── l10n/           # Localization files
  ├── helper/         # Utilities, extensions
  └── main.dart
```

---

## 🌐 Localization

- Supports English (`en`) and Hindi (`hi`)
- Easily add more languages via `lib/l10n/`

---

## 🔒 Privacy & Security

- All data is stored locally and/or securely synced with your Supabase account.
- No analytics or tracking.
- Open source and privacy-first.

---

## 🤝 Contributing

Pull requests, bug reports, and feature suggestions are welcome!  
Please open an issue or submit a PR on [GitHub](https://github.com/ASHWINI-GUPTA/Card-Nudge).

---

## 📄 License

[MIT License](LICENSE)

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Hive](https://docs.hivedb.dev/)
- [Supabase](https://supabase.com/)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)

---