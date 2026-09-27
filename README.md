# Promise

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

## Features

### Currently Implemented (MVP)
- **Create Promise:** Log new commitments with title, recipient, optional description, due date, and optional due time.
- **PostgreSQL Persistence:** Full backend persistence through Serverpod ORM and PostgreSQL.
- **Home Dashboard:** View saved promises as clean Material 3 cards with status indicators and pull-to-refresh.
- **Promise Details View:** Comprehensive details view showing commitment information, schedule, and activity history.
- **Activity History Timeline:** Chronological activity timeline displaying progress updates, status changes, and confirmations.
- **Independent Activity Status:** Each activity progress update supports its own status (`Pending`, `In Progress`, `Completed`) independently from the overall Promise status.
- **Overall Promise Status:** Managed status flow supporting `Pending`, `In Progress`, `Awaiting Confirmation`, and `Completed`.
- **Awaiting Confirmation State:** System-generated status when one party confirms completion while awaiting the second party.
- **Two-Party Completion Confirmation:** A Promise is officially completed ONLY when both Creator and Recipient confirm completion.
- **Serverpod Backend Enforcement:** Serverpod endpoint validates that setting `Completed` requires both parties to have confirmed.
- **Activity Logging:** Automatic transaction logging for promise creation, progress updates, status changes, and two-party confirmations.
- **Full-Screen Android Navigation:** Dedicated `PromisePreparationScreen` and full-screen `AddUpdateScreen` route architecture for Android lifecycle safety.
- **Loading & Error States:** User-friendly loading overlays, retries, and network error handling.
- **Material 3 UI:** Clean Material 3 design system.

> **Key Distinction:** Activity Status and Overall Promise Status are separate concepts. Marking individual activities (e.g. "Database completed") as `Completed` does not automatically complete the overall Promise.

## How It Works

```text
Create Promise
  └─> Prepare / Load Promise Data
       └─> Promise Details
            ├─> Add Progress Updates (Activity Status: Pending / In Progress / Completed)
            ├─> Change Overall Status (Pending / In Progress)
            ├─> Creator Confirmation  ──┐
            └─> Recipient Confirmation ──┴─> Overall Status: Completed (When BOTH confirmed)
```

1. **Creation:** A user creates a promise with a title, recipient, description, and schedule.
2. **Progress Updates:** Participants log progress updates (e.g. "Backend completed") with individual activity statuses.
3. **Completion Confirmation:** Both Creator and Recipient must confirm completion.
4. **Final Completion:** When the second party confirms, Serverpod automatically updates the overall status to `Completed` and logs the completion event.

## Tech Stack

### Frontend
- **Flutter** (Cross-platform UI framework)
- **Dart**
- **Material 3** Design System

### Backend
- **Serverpod** (Dart-based backend framework)
- **PostgreSQL** Database
- **Dart**

### Tools & AI
- **Git** & **GitHub**
- **Android Studio**
- **Google Gemini** / AI-assisted development

## Architecture

```text
Flutter Android / Web App
        ↓
Serverpod Client (`promise_client`)
        ↓
Serverpod Backend (`promise_server`)
        ↓
PostgreSQL Database
```

- **Declarative Models:** Data models are defined in YAML (`.spy.yaml`) files.
- **Protocol Generation:** Serverpod generates strongly-typed client and server protocol code.
- **Activity Relation:** `PromiseActivity` links to `Promise` via `promiseId` foreign key.
- **Backend Rule Enforcement:** Serverpod endpoints validate requests and enforce business rules, including preventing manual `Completed` transitions until both confirmations are present.
## Project Structure

```text
PROMISE/
├── promise_client/    # Generated Serverpod client library
├── promise_flutter/   # Flutter mobile/web application
├── promise_server/    # Serverpod backend application
├── .github/           # GitHub workflows and issue templates
├── AGENTS.md          # Agent instructions & development checklist
└── README.md          # Project documentation
```

### Packages Overview
- **`promise_server`**: Serverpod server package containing models, endpoints, database migrations, and business logic.
- **`promise_client`**: Automatically generated Dart client library imported by the Flutter app.
- **`promise_flutter`**: Flutter frontend containing screens, widgets, and Serverpod client initialization.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started/sdk)
- [Serverpod CLI](https://docs.serverpod.dev/) (`dart pub global activate serverpod_cli`)
- Android Studio / Android Emulator

### Local Development Flow (Windows PowerShell)

1. **Start the Serverpod Backend:**
   ```powershell
   cd D:\GITHUB_REPOS\PROMISE\promise_server
   serverpod start --no-flutter
   ```

2. **Run the Flutter Android App on Emulator:**
   In a separate terminal window:
   ```powershell
   cd D:\GITHUB_REPOS\PROMISE\promise_flutter
   flutter pub get
   flutter run -d emulator-5554 --no-dds --dart-define=SERVER_URL=http://10.0.2.2:8080/
   ```

> **Note:**
> - Android emulator uses `http://10.0.2.2:8080/` to communicate with the local host Serverpod server.
> - Emulator device used during development: `emulator-5554`.

## Development

Useful commands during development:

```powershell
# Regenerate Serverpod client/server code after modifying .spy.yaml models
cd D:\GITHUB_REPOS\PROMISE\promise_server
serverpod generate

# Run static analysis and formatting
dart format .
dart analyze

# Run server unit and integration tests
dart test

# Clean Flutter build artifacts if full rebuild is needed
cd D:\GITHUB_REPOS\PROMISE\promise_flutter
flutter clean
flutter pub get
```

- Press `r` in the Flutter CLI for Hot Reload.
- Press `R` for Hot Restart.
- Press `q` to stop running.

## Testing & Verification

The following scenarios have been verified on Android Emulator (`emulator-5554`) and Flutter Web:

- **Promise Creation:** Form validation, native date/time pickers, and Serverpod transaction persistence.
- **Full-Screen Preparation Route:** Pre-loading details & activities via `PromisePreparationScreen` before opening `PromiseDetailsScreen`.
- **Full-Screen Add Update Route:** Clean progress update logging via `AddUpdateScreen` with zero modal overlay collisions.
- **Activity History Timeline:** Chronological timeline rendering with activity status badges (`Pending`, `In Progress`, `Completed`).
- **Independent Activity Status:** Logging completed activities without affecting overall promise status.
- **Two-Party Completion Confirmation:**
  - Creator confirmation transitions status to `Awaiting Confirmation`.
  - Recipient confirmation transitions status to `Completed`.
  - Same-side repeated confirmation is idempotent (no duplicate events created).
- **Persistence Verification:** All promises, activities, activity statuses, and confirmation flags persist across app restarts in PostgreSQL.
- **Cross-Platform Verification:** Verified on Android Emulator and Flutter Web.

## AI-Assisted Development

This project was developed with AI-assisted coding tools, including Google Gemini, for:
- Code generation & refactoring
- Architecture planning & debugging
- Code reviews & linting
- UI refinement & Material 3 styling
- Test scenario planning & lifecycle verification

All architectural decisions, business rules, and edge-case bug fixes were reviewed and tested manually on Android emulator and web builds.

## Current Limitations

- **Authentication / Identity Verification:** Serverpod Auth is set up in client configuration, but user-identity role binding is not yet enforced; Creator and Recipient confirmation buttons are exposed as explicit controls for MVP testing.
- **Notifications:** Email reminders and push notifications are not yet implemented.
- **Payment & Evidence:** Payment tracking and file attachments are planned, not yet implemented.
- **Production Configuration:** Configured for local development (`http://localhost:8080` / `http://10.0.2.2:8080`).

## Status

Promise is currently a full-stack MVP/hackathon-stage application. Core promise creation, PostgreSQL persistence, activity history tracking, status management, and two-party completion workflows are fully implemented and verified.

Repository: [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
