# Smart Campus Operations System

A Flutter mobile application for university students and staff to manage timetables, view campus announcements, and register for events.

---

## Architecture: Clean Architecture (3-Layer)

```
lib/
├── app/              # Theme, route registry
├── domain/           # Models + use-cases (pure Dart, no dependencies)
│   ├── models/       # User, TimetableEntry, Event, Announcement
│   └── usecases/     # GetTimetable, GetAnnouncements, RegisterForEvent
├── data/             # Data sources + repository implementations
│   ├── local/        # SQLite (DatabaseHelper, TimetableDao, EventDao)
│   ├── remote/       # HTTP (AnnouncementApi → JSONPlaceholder)
│   └── repositories/ # Bridge between domain ↔ data
├── presentation/     # Flutter UI
│   ├── screens/      # LoginScreen, HomeScreen, and tab screens
│   └── widgets/      # Reusable AnnouncementCard, TimetableTile, QrDisplayWidget
└── providers/        # State management (Provider / ChangeNotifier)
```

---

## State Management: Provider

`AuthProvider`, `AnnouncementProvider`, `TimetableProvider`, `EventProvider` — all extend `ChangeNotifier`. Registered at the root via `MultiProvider`.

---

## Database (SQLite)

| Table | Purpose |
|-------|---------|
| `users` | Authenticated users |
| `timetable` | Class schedule (FK → users) |
| `events` | Campus events |
| `registrations` | Student ↔ Event join (UNIQUE constraint) |

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Student | student@campus.lk | 1234 |
| Staff | staff@campus.lk | 1234 |

---

## Device Feature: QR Code Generation

After registering for an event, students receive a QR pass encoded as `CAMPUS_EVENT|{userId}|{eventId}`.

---

## Getting Started

```bash
flutter pub get
flutter run
```
