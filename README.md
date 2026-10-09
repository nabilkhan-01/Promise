# Promise

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

Promise is built around a fundamental rule: **a commitment is not officially complete until both sides confirm it.**

---

## Why Promise?

Every day, people make informal agreements — "I'll review your code by tomorrow," "I'll submit the report on Friday," or "I'll return the equipment by noon." Without a dedicated framework, these verbal or chat-based agreements lack structure, clear deadlines, progress tracking, and mutually acknowledged completion.

Promise solves this problem by turning everyday agreements into structured commitments with:
- **Verified Participants:** Agreements made between accepted friends.
- **Clear Terms & Schedules:** Due dates and optional due times.
- **Chronological History:** Auditable timeline of progress updates and status changes.
- **Two-Party Confirmation:** Completion is only recognized when both Creator and Recipient confirm.
- **Documented Change Requests:** A formal mechanism to request and record changes if circumstances evolve.
- **Terminal Finality:** Completed commitments are archived as immutable, read-only records.

---

## Features

### Authentication & Email Delivery
- **Serverpod Auth Email IDP:** Email authentication managed by Serverpod Auth 4.0.
- **Brevo REST API Email Delivery:** Transactional emails (registration and password resets) delivered via Brevo's HTTPS REST API (`POST https://api.brevo.com/v3/smtp/email`) on port 443.
- **Server-Side Credentials:** Brevo API keys (`brevoApiKey`) are stored exclusively in Serverpod Cloud secrets / `config/passwords.yaml` and are never exposed to the Flutter client.
- **Password Reset Flow:** Complete email-verified password reset with secure 6-digit code verification.
- **Disposable Email Protection:** Authoritative server-side and client-side validation rejecting temporary/disposable email domain providers (e.g., Mailinator, TempMail).
- **User-Facing Error Feedback:** Human-readable error feedback for invalid credentials, unregistered email reset requests, expired/incorrect verification codes, and network issues.
- **Session Persistence:** Authenticated user sessions persist automatically across app restarts via `FlutterAuthSessionManager`.
- **Sign Out:** Secure session token revocation and sign out.

### Friends System
- **User Search:** Search registered Promise users by email or username.
- **Friend Requests:** Send, view pending, accept, and reject friend requests.
- **Friend Removal:** Remove existing friendships when necessary.
- **Friendship-Enforced Commitments:** Promises can only be created for accepted friends.
- **Backend Authorization:** Friendship relationships and privacy rules are enforced on the server.

### Promise Management & Tabbed Dashboard
- **Create Promise:** Log new commitments specifying title, recipient friend, optional description, due date, and optional due time.
- **PostgreSQL Persistence:** All promises, activities, notifications, and friendships are persisted in PostgreSQL via Serverpod ORM.
- **Tabbed Dashboard:** Clean Material 3 dashboard organized into two sections:
  - **Current (`pending`, `in_progress`, `awaiting_confirmation`):** Sorted strictly by nearest due date and due time first.
  - **Completed (`completed`):** Archived commitments sorted newest first.
  - Live section counts (e.g. `Current (2)`, `Completed (4)`) and custom empty state messages (`No active promises yet.`, `No completed promises yet.`).
- **Participant Authorization:** Serverpod backend verifies caller identity against creator and recipient IDs for all operations.

### Persistent In-App Notification System
- **Serverpod + PostgreSQL Notifications:** Full in-app notification engine with persistent database storage (`AppNotification`).
- **Event-Driven Notifications:** Triggered automatically on key events:
  - **Friends:** `friend_request`, `friend_request_accepted`
  - **Promises:** `promise_created`, `promise_updated`, `promise_status_changed`, `change_requested`, `confirmation_requested`, `promise_completed`
- **Dashboard Notification Bell:** App bar notification bell (`🔔`) featuring an unread count badge and periodic background refresh polling while active.
- **`NotificationsScreen`:** Mobile-first screen grouped by `TODAY` and `EARLIER` with unread emphasis, type-specific visual icons, relative timestamps (`5m ago`), "Mark all as read", and tap-to-navigate directly to the referenced Promise or Friend Request.
- **Authenticated Isolation:** Endpoint authorization ensures users can only read or update their own notifications.

### Activity Timeline & Status Tracking
- **Chronological Timeline:** Log tracking creation events, progress updates, status changes, change requests, and completion confirmations.
- **Progress Updates:** Participants can log updates with custom messages and individual activity statuses via the full-screen `AddUpdateScreen`.
- **Independent Activity Statuses:** Activity progress statuses (`Pending`, `In Progress`, `Completed`) operate independently of the overall Promise status.
- **Responsive Status Progress Component:**
  - Responsive visual progress control clearly displaying:
    ```text
    Pending ──> In Progress ──> Awaiting Confirmation ──> Completed
    ```
  - Adapts automatically to a horizontal step layout on wide screens and a vertical step-connected timeline on mobile portrait screens (< 480px), eliminating text wrapping on small displays.
- **Two-Party Completion Rule & Role Awareness:**
  - Explicit user role callout (`Your Role: Creator` / `Your Role: Recipient`).
  - First party confirmation transitions overall status to `Awaiting Confirmation`.
  - Second party confirmation transitions overall status to `Completed`.
- **Terminal Completed State:** Once both parties confirm, a Promise enters `Completed` status and becomes strictly read-only. Further updates, confirmations, status changes, or change requests are permanently blocked.

### Request Changes
- **Request Changes Flow:** Either participant can request changes prior to final completion.
- **Confirmation Reset:** Submitting a change request resets any existing completion confirmations and returns the Promise status to `In Progress`.
- **History Record:** Change request reasons are recorded directly into the promise's activity timeline.

---

## How It Works

```text
User
 ↓
Create Promise
 ↓
Accepted Friend
 ↓
Promise Details
 ├── Progress Updates (Pending / In Progress / Completed)
 ├── Status Tracking (Pending / In Progress / Awaiting Confirmation)
 ├── Activity History Timeline
 ├── Confirm Completion (Creator & Recipient)
 └── Request Changes (Resets Confirmations ──> In Progress)
        ↓
 Two-Party Confirmation
        ↓
    Completed (Terminal & Read-Only)
```

---

## Screens / User Flow

1. **`SignInScreen`:** Registration with email verification code, login, password reset, and disposable email validation.
2. **`PromiseHomePage`:** Main dashboard displaying active and completed commitments, navigation drawer/tabs for Friends.
3. **`FriendsScreen`:** User search, incoming pending friend requests, accept/reject actions, and current friends list.
4. **`CreatePromiseScreen`:** Commitment creation form with friend picker, native date/time pickers, and description input.
5. **`PromisePreparationScreen`:** Full-screen pre-loading route ensuring asynchronous data fetch before opening details.
6. **`PromiseDetailsScreen`:** Detailed commitment schedule, participant status badges, confirmation buttons, request changes modal, and activity timeline.
7. **`AddUpdateScreen`:** Full-screen route for logging progress updates with individual activity statuses.

---

## Tech Stack

### Frontend
- **Framework:** Flutter (Android-first cross-platform UI)
- **Language:** Dart
- **Design System:** Material 3

### Backend
- **Framework:** Serverpod 4.0.3
- **Language:** Dart
- **Database:** PostgreSQL
- **ORM:** Serverpod ORM

### Authentication & Email
- **Identity Provider:** Serverpod Auth IDP (`serverpod_auth_idp_server`, `serverpod_auth_idp_flutter`)
- **Email Delivery:** Brevo Transactional Email REST API (`https://api.brevo.com/v3/smtp/email`)
- **Session Management:** `FlutterAuthSessionManager`

### Tools & AI
- **IDE & Development:** Android Studio
- **Version Control:** Git & GitHub
- **AI Coding Assistance:** Google Gemini

---

## Architecture

```text
Flutter Android App
        ↓ HTTPS
promise_client (Generated Client Protocol)
        ↓ HTTPS
Serverpod Cloud (promise_server)
        ↓ HTTPS :443
Brevo Transactional Email API (api.brevo.com)
        ↓
User Email Inbox
```

```text
Serverpod Backend (promise_server)
        ↓ ORM
PostgreSQL Database
```

> **Security Guarantee:** Brevo API keys (`brevoApiKey`) remain strictly on the Serverpod Cloud backend and are never included or exposed in the Flutter application binary.

---

## Email & Authentication

Promise uses Brevo's Transactional Email REST API over HTTPS port 443 for cloud email delivery:

- **Endpoint:** `POST https://api.brevo.com/v3/smtp/email`
- **Header:** `api-key: <brevoApiKey>`
- **Port:** HTTPS Port 443 (avoids cloud network firewall blocks on raw SMTP ports)

### User-Facing Error Messaging
Promise translates backend authentication exceptions into friendly, actionable UI feedback:

| Scenario | User Message |
| :--- | :--- |
| **Wrong Credentials** | *"Incorrect email or password."* |
| **Unregistered Email Reset** | *"No account found with this email address."* |
| **Invalid Code** | *"That verification code is incorrect. Please try again."* |
| **Expired Code** | *"That verification code has expired. Please request a new code."* |
| **Disposable Email** | *"This email provider is not supported. Please use a permanent email address."* |
| **Delivery Failure** | *"We couldn't send the verification email. Please try again."* |
| **Network Error** | *"Unable to connect to Promise. Please check your connection and try again."* |

---

## Project Structure

```text
PROMISE/
├── promise_client/    # Generated Serverpod client protocol library
├── promise_flutter/   # Flutter cross-platform frontend application
├── promise_server/    # Serverpod backend application (endpoints, ORM models, auth)
├── .github/           # Issue templates and GitHub configurations
├── AGENTS.md          # Agent instructions & development guidelines
└── README.md          # Project documentation
```

### Packages Overview
- **`promise_server`**: Serverpod backend containing endpoints (`emailIdp`, `friend`, `promise`), ORM models (`.spy.yaml`), Brevo email service, and database migrations.
- **`promise_client`**: Generated Dart client library imported by the Flutter application.
- **`promise_flutter`**: Flutter client application containing Material 3 screens, navigation routes, and Serverpod client setup.

---

## Production Deployment

The Promise backend is deployed and running live on **Serverpod Cloud**:

- **Web:** [https://promise.serverpod.space/](https://promise.serverpod.space/)
- **API:** [https://promise.api.serverpod.space/](https://promise.api.serverpod.space/)
- **Insights:** [https://promise.insights.serverpod.space/](https://promise.insights.serverpod.space/)

### Building Release APK for Testers

To compile an Android release APK connected to the production cloud instance:

```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_flutter
flutter clean
flutter pub get
flutter build apk --release --dart-define=SERVER_URL=https://promise.api.serverpod.space/
```

Output APK location:
`promise_flutter/build/app/outputs/flutter-apk/app-release.apk`

---

## Getting Started & Local Development

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started/sdk)
- [Serverpod CLI 4.0.3](https://docs.serverpod.dev/) (`dart pub global activate serverpod_cli`)
- [Docker Desktop](https://www.docker.com/)
- Android Studio / Android Emulator

### Local Development Setup (Windows PowerShell)

1. **Start Local Serverpod Backend:**
   ```powershell
   cd D:\GITHUB_REPOS\PROMISE\promise_server
   serverpod start --no-flutter
   ```

2. **Run Flutter App on Android Emulator:**
   ```powershell
   cd D:\GITHUB_REPOS\PROMISE\promise_flutter
   flutter pub get
   flutter run -d emulator-5554 --no-dds --dart-define=SERVER_URL=http://10.0.2.2:8080/
   ```

---

## Development Commands

### Serverpod Backend (`promise_server`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_server

# Regenerate protocol code after modifying .spy.yaml models
serverpod generate

# Format code and run static analysis
dart format .
dart analyze

# Run backend unit and integration tests
dart test
```

### Flutter Frontend (`promise_flutter`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_flutter

# Format code and run static analysis
dart format .
dart analyze
```

---

## Testing & Verification

### Automated Backend Tests (`dart test`)
- [x] Serverpod server initialization and protocol generation.
- [x] Disposable email validator unit tests (`disposable_email_validator_test.dart`).
- [x] Email IDP endpoint integration tests (`email_idp_endpoint_test.dart`).
- [x] Notification endpoint integration tests (`notification_endpoint_test.dart`).
- [x] Database migrations, model serialization, and user authorization tests (`14/14` tests passing).

### Static Analysis
- [x] `promise_server`: Clean (`No issues found!`).
- [x] `promise_client`: Clean (`No issues found!`).
- [x] `promise_flutter`: Clean (`No issues found!`).

### Manual & Production Verification
- [x] **Production Cloud Registration:** Verified 6-digit verification code delivery to real email inbox via Brevo REST API (`Status: 201`).
- [x] **Password Reset:** Verified email delivery and password reset flow for registered accounts.
- [x] **Disposable Email Protection:** Rejection of temporary email domains (e.g., Mailinator).
- [x] **Friend System:** User search, sending/accepting requests, and unfriending.
- [x] **Promise Lifecycle:** Creating commitments for accepted friends, activity progress updates, request changes, and two-party completion.
- [x] **Terminal State Finality:** Confirmed promises become read-only and reject further edits.
- [x] **Persistence:** Full state restoration across app restarts via PostgreSQL and `FlutterAuthSessionManager`.

---

## AI-Assisted Development

Promise was built with AI-assisted software engineering tools (Google Gemini) for:
- Architecture planning and database model design (`.spy.yaml`).
- Endpoint logic and Flutter screen implementation.
- Real-time debugging, linting, and refactoring.
- Material 3 UI design and navigation routing.
- Test scenario planning and error handling implementation.

All AI-generated code was reviewed, refactored, and tested on Android emulator and production cloud environments.

---

## Current Limitations

- **Push Notifications & Reminders:** Scheduled push notifications and automated email reminders are planned for future updates.
- **Evidence / Attachments:** Photo and document file attachments for promise updates are planned.
- **Payment Tracking:** Payment escrow/tracking integrations are planned for future versions.
- **Search Scale:** User search checks a bounded set of profiles appropriate for MVP scale.

---

## Status

Promise is a full-stack Serverpod 4.0 + Flutter MVP application deployed to Serverpod Cloud. All core features — email authentication with Brevo REST API, friend management, promise creation, progress tracking, two-party completion, and PostgreSQL persistence — are implemented, verified, and running live in production.

**Repository:** [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
