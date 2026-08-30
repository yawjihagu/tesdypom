# TesdyPom 🍅

An MBHTE-TESD branded Pomodoro timer built with Flutter — track your focus sessions, earn XP, unlock achievements, and grow a little plant while you work.

> Built with the official MBHTE-TESD design palette: deep forest green + brass gold on warm cream paper.

## ✨ Features

- **Standard Pomodoro flow** – 25 min work / 5 min break, or fully **custom durations**
- **Gamification**
  - **XP & levels** – earn XP per completed session (20 XP, level up every 100 XP)
  - **Achievements** – 8 unlockable badges with celebration toasts
  - **Daily streak** counter 🔥
- **Stats & history**
  - Persisted via `shared_preferences`
  - **This week** bar chart + today's session count
- **Notifications** – sound alert + haptic feedback on session end
- **MVP touches**
  - Growing **plant mascot** that blooms as you rack up sessions
  - **Confetti** 🎉 + bonus XP when you complete a 4-pomodoro cycle
  - Rotating **motivational quotes** on break
- **Theme** – light cream MBHTE-TESD brand theme (green focus / gold break)

## 🚀 Getting Started

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
  theme.dart         # MBHTE-TESD brand palette & theme
  models.dart        # stats, achievements, motivational quotes
  storage.dart       # persistence layer (shared_preferences)
  pomodoro_page.dart # timer UI, gamification, confetti, mascot
test/
  widget_test.dart   # smoke test
```

## 🛠️ Tech

- **Framework:** Flutter / Dart
- **Persistence:** `shared_preferences`
- **Platforms:** Linux desktop, Android

## 📄 License

Private repository.
