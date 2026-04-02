# Smart Campus Operations System (v2.1.0)

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Repo Size](https://img.shields.io/github/repo-size/BuddhikaBICT-UoR-FoT-6/smart_campus)

A production-grade Flutter mobile application spanning architectures empowering university students and staff to comprehensively process timetables, campus announcements, and event registrations seamlessly.

*The **1.0 Minimum Viable Product** execution explicitly established isolated SQLite primitives mapping internal functionality securely. As of **v2.0**, architectures traverse entirely remote MySQL topologies strictly alongside advanced DevOps pipelines.*

👉 **[View the complete project CHANGELOG tracking structural modifications here](docs/CHANGELOG.md)**

---

## Architecture: Clean Architecture (3-Layer)

```
lib/
├── app/              # Theme, route registry (Dark & Light OLED)
├── core/             # Critical Exceptions & Crashlytics Telemetry Logic
├── domain/           # Models (pure Dart, no dependencies)
├── data/             # Data sources + repository implementations
│   ├── local/        # Strict local SQLite boundaries executing offline persistence
│   └── repositories/ # Bridge mapping repository architectures against Domain
├── presentation/     # Flutter UI (Shimmer components heavily integrated)
│   ├── screens/      # Tri-State isolated screen buffers
│   └── widgets/      # Reusable UI geometries dynamically sizing
└── providers/        # State management memory-isolated
```

---

## State Management: Provider

`AuthProvider`, `AnnouncementProvider`, `TimetableProvider`, `EventProvider` — all extend `ChangeNotifier`. Registered at the root natively via `MultiProvider` actively caching logic seamlessly up to 5-minute threshold limits securely.

---

## Database (SQLite Offline)

| Table | Purpose |
|-------|---------|
| `users` | Authenticated internal memory users |
| `timetable` | Class schedule bounding FK targets |
| `events` | Campus events strictly loaded from Data Access Objects |
| `registrations` | Safely tracked physical student bounds locking logic structurally |

---

## Architecture Initialization
The system implements explicit environment topologies utilizing parameter injections natively supporting Dev/Production structures actively.

```bash
# Extract initialization libraries automatically
flutter pub get

# Launch software utilizing parameterized environment triggers securely
flutter run --dart-define=ENV=dev
```
