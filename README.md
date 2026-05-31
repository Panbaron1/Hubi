# Hubi

A simple, full-screen finger-painting app for kids, built with Flutter.

Draw with chunky brushes in bright colors, switch to "random color" mode for
rainbow strokes, adjust brush size, undo a stroke, or clear the canvas. The app
locks to landscape orientation for a tablet-friendly drawing surface.

## Features

- Free-hand drawing on a full-screen white canvas
- 11-color palette plus a random vivid-color mode
- Adjustable brush size (2–48 px)
- Undo last stroke / clear canvas
- Landscape-locked, distraction-free UI

## Tech

- **Flutter** (Dart SDK `^3.12.0`), Material 3
- Rendering via `CustomPainter` + `Canvas` drawing primitives
- Touch input via `GestureDetector` pan events
- No external dependencies beyond the Flutter SDK

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.12+)
- Android toolchain (Android Studio or the Android SDK + cmdline-tools)
- Run `flutter doctor` and resolve any reported issues

## Build & Run

```bash
git clone https://github.com/Panbaron1/Hubi.git
cd Hubi
flutter pub get        # fetch dependencies
flutter devices        # list connected devices / emulators
flutter run            # debug build on a connected device
```

### Release APK (Android)

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Install the APK on a device with `flutter install`, or copy it to the phone and
install manually (enable installs from unknown sources).

## Other Platforms

Only the **Android** platform is scaffolded. To add iOS, web, or desktop:

```bash
flutter create .          # regenerates missing platform folders
flutter run -d chrome     # e.g. run on web
```

> iOS builds require macOS with Xcode.
