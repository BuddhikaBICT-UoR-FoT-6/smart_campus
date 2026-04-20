# CHANGELOG

All notable changes to the Smart Campus Operations System will be documented in this file.

## [3.1.0] - Academic Semester & Performance Management (2026-04-20)
### Added
- **Academic Calendar System**: Migrated to Database Schema v4 introducing `academic_calendar` tracking for 6-month semesters.
- **Semester Overview**: Interactive dashboard for academic weeks including touchable tiles for historical attendance tracking.
- **Academic Performance Dashboard**: Integrated GPA calculation logic and semester-wise grading tables with data visualization.
- **Profile Self-Management**: Developed `EditProfileScreen` allowing students to manage personal and emergency details securely.
- **Campus Contacts Directory**: Added instant-access directory for university officials and departmental contacts (ICT, BST, ET).
- **UX Refinements**: Implemented Pull-to-Refresh on Announcement screens and optimized dark mode typography scaling.

## [2.2.0] - Smart Campus Operations Overhaul (2026-04-18)
### Added
- Integrated **Campus Map** using `flutter_map` with OpenStreetMap and user location tracking via `geolocator`.
- Implemented **QR Code Scanner** for staff members to verify event registrations in real-time using `mobile_scanner`.
- Deployed **Push Notifications** service for urgent announcements using `flutter_local_notifications`.
- Added "Urgent" announcement posting capability for Staff users with automated device notifications.
- Added quick access buttons for Map and QR Scanner on the `HomeScreen` AppBar.

## [2.1.0] - SQLite Offline Fallback (2026-04-02)
### Changed
- Rolled back overarching MySQL integration layers directly targeting local SQLite routines mapping structural offline bounds smoothly supporting hardware agnostic demonstrations.

## [2.0.0] - Full Stack Database Migration & App Polish (2026-04-01)
### Added
- Native `mysql1` Dart socket bindings replacing legacy SQLite implementation required for grading specifications.
- Fully generated `database/init.sql` script for automated test architecture instantiation.
- Custom vector graphics generating App Launcher Icons bridging standard Apple HIG/Material boundaries.
- Native Android/iOS Splash Screen implementations via `flutter_native_splash`.
- True-Black OLED Dynamic Dark Mode (`AppTheme.dark`) utilizing automated system environment bindings.
- Fully synchronized MySQL backend bridging Announcements, Timetables, Events, and User Sessions.
- `MysqlAuthDao` enforcing cryptographic password boundary checks traversing remote MySQL architecture.

## [1.5.0] - DevOps & Telemetry (2026-03-20)
### Added
- Environment Flavors configurations mapping custom API origins utilizing `--dart-define=ENV=dev` injection.
- `CrashlyticsService` architectural facade abstracting telemetry capture patterns correctly.
- GitHub Actions CI/CD pipeline script `.github/workflows/flutter.yml` enforcing pull request compilation checks.

## [1.4.0] - Production Testing (2026-03-17)
### Added
- Structured E2E automated driver bounds (`integration_test/app_test.dart`) executing tap mechanics visually.
- Systemic boundary data manipulation mapping provider memory isolation using `flutter test`.

## [1.3.0] - UI Polish & Theming (2026-03-15)
### Added
- Systemic `Shimmer` skeletons generated seamlessly mitigating default Cumulative Layout Shifts natively.
- Eliminated all static magic sizing parameters by deploying global `AppConstants` tokenization.

## [1.2.0] - Resilience & Tri-State UI (2026-03-13)
### Added
- Deployed a hard 5-minute memory caching threshold preventing extraneous API requests across app lifecycles.
- Replaced ambiguous `Exception` tracking with mapped explicit `AppException` boundaries natively.
- Scaffolded standardized global Tri-State architecture strictly mapping Loading / Data / Retry Error states visually.

## [1.1.0] - Security & Validation (2026-03-10)
### Added
- Abstracted persistent system caching securely relying against Android Keystore frameworks mapped via `flutter_secure_storage`.
- Developed mock simulation routines analyzing explicitly structured JSON Web Token configurations and timestamps.
- Implemented Regex logic analyzing structural character anomalies guarding initial authentication buffers natively.

## [1.0.0] - Minimum Viable Product Release (MVP)
*Baseline prototype architecture constructed containing foundational clean layered architectures spanning local SQLite definitions and primitive Data Transfer Providers.*
