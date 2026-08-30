# TesdyPom 🍅

An AJ's branded Pomodoro timer built with Flutter — track your focus sessions, tag tasks, jot notes, hit your daily goal, and earn XP while you work.

> Built with the AJ's design palette: deep forest green + brass gold on warm cream paper.

## ✨ Features

- **Standard Pomodoro flow** – 25 min work / 5 min break, or fully **custom durations**
- **Task tagging** – tag each session with what you're working on (pick a past task or type a new one)
- **Session notes** – add an optional note to every focus session
- **Daily goal** – set a target of pomodoros per day and watch a progress bar fill (turns gold when reached)
- **Auto-start** – optionally auto-begin each session so the timer keeps flowing
- **Stats dashboard**
  - Total focus time, today's minutes, best day, and daily average
  - Per-task breakdown so you can see where your time goes
  - Persisted via `shared_preferences`
- **This week** bar chart + today's session count + daily streak 🔥
- **Gamification**
  - **XP & levels** – earn XP per completed session (20 XP, level up every 100 XP)
  - **Achievements** – 8 unlockable badges with celebration toasts
  - **Confetti** 🎉 + bonus XP when you complete a 4-pomodoro cycle
- **Notifications** – sound alert + haptic feedback on session end
- **Rotating motivational quotes** on break
- **Theme** – light cream AJ's brand theme (green focus / gold break)

## 📲 Install on your phone

### Android (phones/tablets)

The app ships as an Android APK on the **Releases** page. To install it:

1. Open the releases page, download `app-release.apk`:
   `https://github.com/yawjihagu/tesdypom/releases`
2. Transfer the `.apk` file to your phone (USB cable, or download it directly in the phone's browser).
3. Tap the file. Android will warn that it's "from an unknown developer" — tap **Install anyway** / **Allow from this source**. The app is not on the Play Store, so this step is required.
4. Open **TesdyPom** from your app drawer.

> ⚠️ The APK is signed with a development key, which is normal for sideloaded apps and fine for personal use.

### iPhone / iOS

**Not yet available.** TesdyPom is currently built for **Android and Linux only**. iOS support requires:

- A Mac with **Xcode**
- Adding the `ios/` platform to this Flutter project
- An Apple Developer account to install on a device / publish to the App Store

Until then, the iOS version isn't available to install. Follow this repo's releases to be notified when it ships.

---

## 🚀 Getting Started (for developers)

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+)
- Linux desktop: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- Android: Android SDK

### Run

```bash
git clone https://github.com/yawjihagu/tesdypom.git
cd tesdypom
flutter pub get
flutter run -d linux      # or -d <android-device-id>
```

Or run the built release binary directly:

```bash
flutter build linux --release
./build/linux/x64/release/bundle/tesdypom
```

### Test & analyze

```bash
flutter analyze
flutter test
```

## 🏗️ Project Structure

```
lib/
  main.dart          # entry point
  theme.dart         # AJ's brand palette & theme
  models.dart        # stats, sessions, achievements, motivational quotes
  storage.dart       # persistence layer (shared_preferences)
  pomodoro_page.dart # timer UI, tasks, notes, goal, stats, gamification
test/
  widget_test.dart   # smoke test
```

## 🛠️ Tech

- **Framework:** Flutter / Dart
- **Persistence:** `shared_preferences`
- **Platforms:** Linux desktop, Android

## 📄 License

Public repository, made available for educational purposes.