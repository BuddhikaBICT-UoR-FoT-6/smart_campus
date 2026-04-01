# Smart Campus Operations System (v2.0.0)

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
│   ├── remote/       # Native bindings executing MySQL Database Queries
│   └── repositories/ # Bridge mapping MySQL architectures against Domain
├── presentation/     # Flutter UI (Shimmer components heavily integrated)
│   ├── screens/      # Tri-State isolated screen buffers
│   └── widgets/      # Reusable UI geometries dynamically sizing
└── providers/        # State management memory-isolated
```

---

## State Management: Provider

`AuthProvider`, `AnnouncementProvider`, `TimetableProvider`, `EventProvider` — all extend `ChangeNotifier`. Registered at the root natively via `MultiProvider` actively caching logic seamlessly up to 5-minute threshold limits securely.

---

## Remote Database (MySQL via `mysql1`)

| Table | Purpose |
|-------|---------|
| `users` | Securely tracks authenticated system properties safely |
| `timetable` | Tracks class schedules dynamically mapping back to users |
| `events` | Structured representation tracking campus routines |
| `user_events` | Linking table securely binding users against registration events dynamically |
| `announcements` | Structured architecture retaining communication channels globally |

---

## Architecture Initialization
The system implements explicit environment topologies utilizing parameter injections natively supporting Dev/Production structures actively.

```bash
# Extract initialization libraries automatically
flutter pub get

# Launch software utilizing parameterized environment triggers securely
flutter run --dart-define=ENV=dev
```
