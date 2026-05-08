# NOTES APP

A full-featured cross-platform notes app built with Flutter and Firebase. Supports real-time CRUD operations, email/password authentication, offline access, local search, and persistent sessions — all without any manual local storage management.

---

## Features

- Email and password sign up, login, and logout
- Persistent login session — stays logged in after app restart
- Create, read, update, and delete notes in real time
- Notes sync instantly across sessions via Firestore streams
- Full offline support — cached notes load with no internet
- Local search by title
- Pull to refresh
- Offline banner — shows when device has no connection
- Proper empty states for no notes, no search results, and errors
- User-friendly error messages for every Firebase Auth error code
- Input validation on all forms
- Confirmation dialogs before delete and logout
- Password visibility toggle
- Platform-aware loading indicator (Cupertino on iOS, Material on Android)

---

## Tech Stack

| Layer | Technology |

| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Auth — Email & Password |
| Database | Cloud Firestore |
| Offline Cache | Firestore Persistence |
| State Management | GetX |
| Routing | GetX Named Routes |
| Connectivity | connectivity_plus |
| UI Scaling | flutter_screenutil |
| Date Formatting | intl |

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   └── app_routes.dart
│   ├── services/
│   │   └── connectivity_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       └── platform_loader.dart
└── modules/
    ├── splash/
    │   └── splash_view.dart
    ├── auth/
    │   ├── controllers/
    │   │   └── auth_controller.dart
    │   └── views/
    │       ├── login_view.dart
    │       └── signup_view.dart
    └── notes/
        ├── controllers/
        │   └── notes_controller.dart
        ├── models/
        │   └── note_model.dart
        └── views/
            ├── home_view.dart
            └── add_edit_note_view.dart
```

---

## Architecture

This app follows MVC pattern organized by feature modules. Views never talk to Firebase directly — all business logic lives in GetX controllers.

```
View (Obx) ──► Controller (GetxController) ──► Firebase
     ◄──────────── RxList / RxBool ◄──────────── Stream
```

### Controller Registration

| Controller | Registered with Get.put() | Accessed with Get.find() |
|---|---|---|
| AuthController | LoginView | SignupView, HomeView |
| NotesController | HomeView | AddEditNoteView |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.41.0 or higher
- Dart SDK 3.10.0 or higher
- A Firebase project
- Xcode (for iOS builds)
- Android Studio or VS Code

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/notevault.git
cd notevault
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase setup

**Create a Firebase project**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** and follow the steps
3. In **Authentication** → **Sign-in method** → enable **Email/Password**
4. In **Firestore Database** → **Create database** → choose **Production mode**

**Android**

1. In Firebase Console → Project Settings → Add Android app
2. Enter your package name (found in `android/app/build.gradle` as `applicationId`)
3. Download `google-services.json`
4. Place it at `android/app/google-services.json`

**iOS**

1. In Firebase Console → Project Settings → Add iOS app
2. Enter your bundle ID (found in Xcode → Runner → Signing & Capabilities)
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into the `Runner/Runner` folder in Xcode
6. Make sure **Copy items if needed** is checked and **Runner** target is ticked

### 4. Firestore security rules

Go to Firestore → Rules and paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.user_id;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.user_id;
    }
  }
}
```

### 5. Run the app

```bash
# Android
flutter run

# iOS — install pods first
cd ios && pod install && cd ..
flutter run
```

---

## iOS Specific Setup

### Minimum deployment target

Open `ios/Podfile` and set:

```ruby
platform :ios, '13.0'
```

### Info.plist

The `ios/Runner/Info.plist` already includes the required keys:

- `NSAppTransportSecurity` — allows Firebase secure HTTPS connections
- `UIBackgroundModes` with `fetch` and `remote-notification` — enables Firestore background sync

### Build for device

1. Open `ios/Runner.xcworkspace` in Xcode — always use `.xcworkspace`, never `.xcodeproj`
2. Runner → Signing & Capabilities → set your Apple Developer Team
3. Set a unique Bundle Identifier

### Common iOS errors

| Error | Fix |
|---|---|
| pod install fails | Run `pod repo update` then `pod install` again |
| Minimum deployment target error | Set `platform :ios, '13.0'` in Podfile |
| GoogleService-Info.plist not found | Add via Xcode drag-and-drop, not Finder |
| Build fails after flutter clean | Delete `ios/Pods` and `ios/Podfile.lock`, then `pod install` |

---

## How It Works

### Session Persistence

Firebase Auth automatically saves the login token to the device's secure storage (Keychain on iOS, SharedPreferences internally on Android). On every app launch, `SplashView` checks `FirebaseAuth.instance.currentUser` — if non-null, the user goes straight to Home. No manual token storage needed.

### Offline Cache

Firestore offline persistence is enabled in `main.dart`:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Every note fetched is saved to device disk automatically. When the app opens with no internet, Firestore serves from this cache — the stream still fires and notes appear normally.

### Search

Search is 100% local — no Firestore calls on every keystroke:

```
Firestore stream → _allNotes (master list)
                        │
               searchController listener
                        │
                  _applyFilter()
                        │
               filteredNotes → UI (Obx)
```

When new data arrives from Firestore while search is active, the filter re-runs automatically so results stay accurate.

### Connectivity

`ConnectivityService` is a `GetxService` registered at app startup. It listens to network changes via `connectivity_plus` and exposes `isConnected` as an `RxBool`. Before every Firebase operation, `checkAndAlert()` is called — if offline, it shows a snackbar and returns early so no spinner ever gets stuck.

---

## Data Model

Each note stored in Firestore:

```
notes/{docId}
├── id          String    — Firestore document ID
├── title       String    — Note title
├── content     String    — Note body
├── user_id     String    — UID of the owner
├── created_at  Timestamp — Creation time
└── updated_at  Timestamp — Last edit time
```

---

## Auth Error Messages

### Login

| Firebase Code | Message |
|---|---|
| invalid-credential | Email or password is incorrect. Please check and try again. |
| user-not-found | No account found with this email. Please sign up first. |
| wrong-password | Incorrect password. Please try again. |
| user-disabled | This account has been disabled. Please contact support. |
| too-many-requests | Too many failed attempts. Please wait a few minutes. |
| network-request-failed | No internet connection. Please check your network. |

### Signup

| Firebase Code | Message |
|---|---|
| email-already-in-use | An account with this email already exists. Please log in instead. |
| weak-password | Your password is too weak. Please use at least 6 characters. |
| invalid-email | The email address you entered is not valid. |
| network-request-failed | No internet connection. Please check your network. |

---

## Dependencies

```yaml
firebase_core: ^3.1.0
firebase_auth: ^5.1.0
cloud_firestore: ^5.1.0
get: ^4.6.6
connectivity_plus: ^6.0.3
flutter_screenutil: ^5.9.0
intl: ^0.19.0
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
