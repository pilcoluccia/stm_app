# STM App — Student Task Management

Flutter application for managing student tasks, study sessions, and academic analytics. Built with Firebase Authentication and local SQLite storage.

---

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.6.0 or higher**
- Dart SDK **3.6.0 or higher**
- A Google account with access to the Firebase project
- For Android: Android Studio + Android SDK, or a physical device with USB debugging enabled
- For Web: Google Chrome

Verify your Flutter installation:

```bash
flutter doctor
```

All items should be green before continuing.

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/pilcoluccia/stm_app.git
cd stm_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase configuration

The file `lib/firebase_options.dart` is already included in the repository with the project configuration for `stm-app-cihe`. No additional Firebase setup is required.

---

## Running on Chrome (Web)

Google Sign-In is supported on web.

```bash
flutter run -d chrome
```

For a faster load use release mode:

```bash
flutter run -d chrome --release
```

The app will open automatically in a new Chrome tab.

### Google Sign-In on Web

The Google Sign-In button is visible and fully functional in the browser. Make sure the **People API** is enabled in the Google Cloud Console for the project (`538559006995`).

---

## Running on Android

### Option A — Physical device

1. Enable **Developer Options** and **USB Debugging** on your Android phone.
2. Connect the phone via USB.
3. Verify Flutter detects it:

```bash
flutter devices
```

4. Run:

```bash
flutter run -d <device-id>
```

Or simply (if only one device is connected):

```bash
flutter run
```

### Option B — Android Emulator

1. Open Android Studio → **Device Manager** → create and start an emulator (API 26 or higher recommended).
2. Run:

```bash
flutter run
```

---

## Running on Windows Desktop

Google Sign-In is **not available** on Windows desktop (Firebase SDK limitation). Email and password login works normally.

```bash
flutter run -d windows
```

---

## Login credentials (Firebase)

Register a new account from the app using **Register** on the login screen, or use Google Sign-In on web/Android.

Role is determined automatically by email:
- Emails containing `lecturer` → **Lecturer** view
- All other emails → **Student** view

---

## Features

| Feature | Description |
|---|---|
| Authentication | Email/password + Google Sign-In (web & Android) |
| Dashboard | Upcoming deadlines and task overview |
| Tasks | Create, complete, and filter tasks by priority |
| Calendar | Event and deadline calendar |
| Study | Pomodoro timer (25 min focus / 10 min break) |
| Analytics | Pie chart and bar chart with real task data |
| Profile | User info, theme selector, notification settings |

---

## Tech stack

- **Flutter** 3.6+
- **Firebase Auth** — authentication
- **SQLite** (`sqflite`) — local task storage
- **fl_chart** — analytics charts
- **google_sign_in** — Google OAuth (web & mobile)
