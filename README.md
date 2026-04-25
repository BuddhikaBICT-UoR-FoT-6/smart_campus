# Smart Campus Operations System (v3.1.0)

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Repo Size](https://img.shields.io/github/repo-size/BuddhikaBICT-UoR-FoT-6/smart_campus)

A production-grade Flutter mobile application spanning architectures empowering university students and staff to comprehensively process timetables, campus announcements, and event registrations seamlessly.

## Key Features (v3.2.0 Updates)
- 📅 **Academic Level Assignment**: Levels (Years 1-4) & dual semesters mapped across users to filter institutional content.
- 🩺 **Medical Approvals Engine**: Photographic document verification pipeline allowing admin status updates.
- 🗄️ **Dual Database Synchronization**: Local SQLite queries with background remote MySQL updates.
- 📊 **Performance Dashboard**: Real-time GPA calculation, semester-wise grading tables, and visual performance tracking.
- 👤 **Profile Self-Management**: Comprehensive user profile editing including personal and emergency contact details.
- 🏢 **Campus Directory**: Instant access to university contacts (Dean, AR, HODs) for ICT, BST, and ET departments.
- 🔍 **QR Verification**: Staff-facing scanner using `mobile_scanner` to validate event entries.

*The **3.2.0 Iteration** successfully transitions persistence pipelines securely.*

👉 **[View the complete project CHANGELOG tracking structural modifications here](CHANGELOG.md)**

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

## Database (SQLite Offline v5 + MySQL Background Sync)

| Table | Purpose |
|-------|---------|
| `users` | Authenticated users with Profile levels + semester tags |
| `timetable` | Class schedule bounding level/semester targets |
| `academic_calendar` | 20-week semester structure tracking |
| `academic_results` | Student grades and GPA telemetry |
| `medical_submissions` | Admin-facing health waiver storage bounds |
| `events` | Campus events loaded via DAOs |
| `registrations` | Safely tracked physical student bounds |

---

## Architecture Initialization
The system implements explicit environment topologies utilizing parameter injections natively supporting Dev/Production structures actively.

```bash
# Extract initialization libraries automatically
flutter pub get

# Launch software utilizing parameterized environment triggers securely
flutter run --dart-define=ENV=dev
```
