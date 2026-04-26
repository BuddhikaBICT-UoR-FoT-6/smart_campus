# Smart Campus Operations System (v3.2.0)

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A production-grade Flutter platform empowering continuous university workflows comfortably.

## Roadmap & Milestone Updates
- **MVP v1.0.0**: Initial baseline offline data access objects for user logic.
- **v2.1.0**: Advanced academic GPA analytics telemetry.
- **v3.2.0**: Dual backends sync capabilities and administrative medical waivers.

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
