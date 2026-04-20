# Smart Campus Operations System (v3.1.0)

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Repo Size](https://img.shields.io/github/repo-size/BuddhikaBICT-UoR-FoT-6/smart_campus)

A production-grade Flutter mobile application spanning architectures empowering university students and staff to comprehensively process timetables, campus announcements, and event registrations seamlessly.

## Key Features (v3.1.0 Updates)
- 📅 **Academic Calendar Tracking**: Structured 6-month semester calendar with academic weeks, exams, and vacations (DB v4).
- 📊 **Performance Dashboard**: Real-time GPA calculation, semester-wise grading tables, and visual performance tracking.
- 👤 **Profile Self-Management**: Comprehensive user profile editing including personal and emergency contact details.
- 🏢 **Campus Directory**: Instant access to university contacts (Dean, AR, HODs) for ICT, BST, and ET departments.
- 🗺️ **Interactive Campus Map**: Built with `flutter_map` and `geolocator` for real-time location tracking.
- 🔍 **QR Verification**: Staff-facing scanner using `mobile_scanner` to validate event entries.
- 🔔 **UX Refinements**: True-Black OLED dark mode support and pull-to-refresh announcement workflows.

*The **1.0 Minimum Viable Product** execution explicitly established isolated SQLite primitives mapping internal functionality securely. As of **v3.1**, the app features advanced semester management and personal academic telemetry.*

👉 **[View the complete project CHANGELOG tracking structural modifications here](docs/CHANGELOG.md)**

---

## Architecture: Clean Architecture (3-Layer)

```
lib/
├── app/              # Theme, route registry (Dark & Light OLED)
├── core/             # Critical Exceptions, Crashlytics & Notification Service Logic
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

`AuthProvider`, `AnnouncementProvider`, `TimetableProvider`, `EventProvider`, `CalendarProvider`, `ThemeProvider` — all extend `ChangeNotifier`. Registered at the root natively via `MultiProvider` actively caching logic seamlessly.

---

## Database (SQLite Offline v4)

| Table | Purpose |
|-------|---------|
| `users` | Authenticated internal memory users + Profile data |
| `timetable` | Class schedule bounding FK targets + Attendance |
| `academic_calendar` | 20-week semester structure tracking |
| `academic_results` | Student grades and GPA telemetry |
| `events` | Campus events strictly loaded from Data Access Objects |
| `registrations` | Safely tracked physical student bounds locking logic |

---

## Architecture Initialization
The system implements explicit environment topologies utilizing parameter injections natively supporting Dev/Production structures actively.

```bash
# Extract initialization libraries automatically
flutter pub get

# Launch software utilizing parameterized environment triggers securely
flutter run --dart-define=ENV=dev
```
