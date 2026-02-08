# lanka_connect

A new Flutter project with Firebase integration.

## Firebase Setup

⚠️ **Important**: Before running this app, you must configure Firebase for iOS and Android.

**Note:** The `lib/firebase_options.dart` file is gitignored for security reasons (contains API keys). 
You need to generate it using one of the methods below.

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup instructions.

### Quick Setup

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase (this will create the required firebase_options.dart file):
   ```bash
   firebase login
   flutterfire configure --project=lankaconnect-app
   ```

3. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

### Alternative Manual Setup

If FlutterFire CLI doesn't work, you can manually copy the template:

```bash
cp .firebase_templates/firebase_options.dart lib/
# Then edit lib/firebase_options.dart and replace placeholder values with your actual Firebase credentials
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
