# Firebase Configuration Guide

This project is configured to use Firebase for both iOS and Android platforms. To complete the setup, you need to configure Firebase with your actual project credentials.

## Prerequisites

1. A Firebase project created at [Firebase Console](https://console.firebase.google.com/)
2. Flutter SDK installed
3. FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Automated Setup (Recommended)

The easiest way to configure Firebase is to use the FlutterFire CLI:

```bash
# Make sure you're logged into Firebase
firebase login

# Run FlutterFire configure
flutterfire configure --project=lankaconnect-app
```

This will automatically:
- Generate `lib/firebase_options.dart` with your project's configuration
- Create `android/app/google-services.json` for Android
- Create `ios/Runner/GoogleService-Info.plist` for iOS

## Manual Setup (Alternative)

If you prefer to manually configure Firebase or if the FlutterFire CLI doesn't work:

### Android Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`lankaconnect-app`)
3. Add an Android app with package name: `com.example.lanka_connect`
4. Download the `google-services.json` file
5. Replace the template file at `android/app/google-services.json` with your downloaded file

### iOS Configuration

1. In Firebase Console, add an iOS app with bundle ID: `com.example.lankaConnect`
2. Download the `GoogleService-Info.plist` file
3. Replace the template file at `ios/Runner/GoogleService-Info.plist` with your downloaded file

### Update firebase_options.dart

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase project configuration:

- `apiKey`: Your platform-specific API key
- `appId`: Your platform-specific App ID
- `messagingSenderId`: Your project's messaging sender ID
- `projectId`: Should already be set to `lankaconnect-app`
- `storageBucket`: Should already be set to `lankaconnect-app.firebasestorage.app`

## Verification

After configuration, run your app:

```bash
flutter run
```

The app should initialize Firebase without errors. Check the console/logs for any Firebase initialization messages.

## Security Note

The following files contain sensitive Firebase configuration and are gitignored:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

**Never commit these files to version control.**

## Firebase Emulator (For Local Development)

If you want to use Firebase Emulator for local development:

1. Start the emulator: `firebase emulators:start`
2. The app is already configured to use emulator settings from `firebase.json`

The emulator configuration is in `firebase.json`:
- Auth: http://localhost:9099
- Firestore: http://localhost:8080
- Storage: http://localhost:9199
- Functions: http://localhost:5001
- UI: http://localhost:4000
