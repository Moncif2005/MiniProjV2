# 🔔 FCM Push Notifications — Integration Guide

## What was added

| File | What changed |
|---|---|
| `lib/services/fcm_service.dart` | **NEW** — Handles permission, token save/refresh/clear, foreground display, and tap navigation |
| `lib/services/notifications_service.dart` | Updated `_push()` to embed `fcmToken` + `fcmSent: false` in every notification doc |
| `lib/services/auth_service.dart` | `signOut()` now calls `FcmService.clearToken()` first |
| `lib/screens/auth_wrapper.dart` | Calls `FcmService.instance.init(context)` after user data loads |
| `lib/main.dart` | Registers background handler + iOS foreground options before `runApp` |
| `functions/index.js` | **NEW** Cloud Function — fires on every new notification doc, sends FCM push |
| `functions/package.json` | **NEW** Node 20 dependencies |
| `firebase.json` | **NEW** Firebase project config |
| `.firebaserc` | **NEW** Points to `formanova-a3d7c` |

---

## Step 1 — Add Flutter packages

In your `pubspec.yaml`, add:

```yaml
dependencies:
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0
```

Then run:
```bash
flutter pub get
```

---

## Step 2 — Android setup

### 2a. `android/app/build.gradle`
Make sure `minSdkVersion` is at least **21**:
```groovy
defaultConfig {
    minSdkVersion 21
}
```

### 2b. `android/app/src/main/AndroidManifest.xml`
Add inside `<application>`:
```xml
<!-- FCM default channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="formanova_high" />

<!-- FCM default icon (use your app icon) -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<!-- FCM default color -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
```

Add inside `<activity>` (for tap-to-open):
```xml
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

### 2c. Create `android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#155DFC</color>
</resources>
```

---

## Step 3 — iOS setup

### 3a. Enable Push Notifications capability
In Xcode → your target → **Signing & Capabilities** → `+ Capability` → **Push Notifications**

### 3b. Enable Background Modes
Add **Background Modes** capability, check:
- ✅ Background fetch
- ✅ Remote notifications

### 3c. `ios/Runner/AppDelegate.swift`
```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3d. Upload APNs key to Firebase Console
1. Apple Developer → **Certificates, Identifiers & Profiles** → **Keys** → Create a key with **Apple Push Notifications service (APNs)**
2. Download the `.p8` file
3. Firebase Console → Project Settings → **Cloud Messaging** → iOS app → Upload APNs Auth Key

---

## Step 4 — Deploy the Cloud Function

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

You should see:
```
✔ functions[sendPushOnNotification]: Successful create operation.
```

---

## Step 5 — Firestore Security Rules

Add this to your `firestore.rules` to allow the function to write `fcmToken`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;

      match /notifications/{notifId} {
        allow read, write: if request.auth.uid == uid;
      }
    }
  }
}
```

---

## How it works end-to-end

```
App action (e.g. apply to job)
        │
        ▼
NotificationsService._push()
  → writes Firestore doc with:
      title, body, type, isUnread: true
      fcmToken: "<device token>"
      fcmSent: false
        │
        ▼
Cloud Function (sendPushOnNotification) fires
  → reads fcmToken from doc
  → calls FCM HTTP v1 API
  → device receives push notification
  → sets fcmSent: true, deletes fcmToken from doc
        │
        ▼
User taps notification
  → FcmService._handleNavigation()
  → navigates to correct screen
```

---

## Testing

### Send a test notification manually (Firebase Console)
1. Firebase Console → **Messaging** → **Send your first message**
2. Notification title: `Test`, body: `Hello!`
3. Target: your app package name
4. Send

### Test via Firestore (simulates the full flow)
Manually add a document in Firestore:
```
users / <your-uid> / notifications / test123
{
  title: "Test Push",
  body: "This is a test",
  type: "system",
  isUnread: true,
  fcmToken: "<paste your token>",
  fcmSent: false,
  createdAt: <server timestamp>
}
```
The Cloud Function will fire within seconds and push to the device.
