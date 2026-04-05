# Changelog

All notable changes to this project will be documented in this file.

## [5.0.0] - 2026-04-05
### Added
- **Administrative Subject Management**: New dashboard module for Superadmins to manage the university curriculum (Level, Semester, Credits).
- **Staff LMS Portal**: Enabled role-based access for staff to manage course materials and uploads.
- **Registration Deadlines**: Implemented global enrollment lock-out logic based on system configuration.
### Fixed
- **Authentication Hardening**: Unified login logic to use database-resident hashed passwords exclusively.
- **UI Performance**: Resolved Hero animation tag collisions across the administrative modules.
- **Flutter 3.x Compatibility**: Migrated deprecated `value` properties in dropdowns to `initialValue`.
- **Database Cleanup**: Removed redundant table definitions and optimized schema initialization.

## [4.1.0] - 2026-04-03
### Added
- Admin Results Management: Level, Marks, and Credits fields added to the result entry form.
- Automated Grade and GPA calculation from raw marks using standard Sri Lankan grading scale (A+, A, A-, B+, ..., E).
- Automated SGPA (Semester GPA) calculated per semester using weighted credit formula.
- Automated CGPA (Cumulative GPA) across all semesters with live Degree Class determination (First Class, Second Upper, etc.).
- Premium Academic Standing analytics card displayed in Admin Results screen.
### Fixed
- Admin Dashboard Management Module tiles: text now correctly switches to white in night mode.

## [4.0.0] - 2026-04-30
### Added
- Academic Portal (Course Registration, LMS, Attendance Analytics).
- Integrated native device APIs (Camera for Medicals, Native Dialer/Mailer for Contacts).
- UI/UX Refinements (Dark Mode theme fixes, interactive DatePickers).
- CI/CD build optimizations (ABI Splitting reducing APK size).

## [3.2.0] - 2026-04-26
### Added
- Superadmin student level assignment flows safely mapped across background SQL tables.
- Structured asynchronous document uploads accommodating approval pipelines smoothly.
- Dual database triggers connecting local schemas and live MySQL instances reliably.

## [2.1.0] - 2026-03-12
### Added
- Integrated dynamic academic evaluation telemetry and visual charting modules.
- Formatted clean architecture boundaries safely.

## [1.0.0] - 2026-01-15
### Added
- Initial operational framework established offline capability bounds securely.
