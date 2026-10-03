# Promise

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

Promise is built around a fundamental rule: **a commitment is not officially complete until both sides confirm it.**

---

## Features

### Authentication
- **Serverpod Email IDP:** Email-based account authentication managed through Serverpod Auth 4.0.
- **Email Verification During Registration:** Verification codes sent upon new user registration.
- **Brevo SMTP Integration:** Transactional email delivery powered by Brevo SMTP for account creation and password resets.
- **Password Reset Flow:** Full email-verified password reset with secure code verification and new password creation.
- **User-Facing Error Feedback:** Clear, human-readable error messages for wrong passwords, unregistered emails, invalid/expired verification codes, and network/delivery issues.
- **Disposable Email Protection:** Strict rejection of temporary email providers (e.g., Mailinator, TempMail) at both client and server levels.
- **Session Persistence:** Secure session token management persisted across app restarts via `FlutterAuthSessionManager`.
- **Server-Side Credential Protection:** All SMTP keys and passwords remain server-side in `config/passwords.yaml`.
- **Streamlined Security:** Clean email-only authentication flow without Google Sign-In overhead or third-party OAuth SDK dependencies.

### Friends
- **User Search:** Search for registered Promise users by email or username.
- **Friend Requests:** Send, receive, view pending, accept, and reject friend requests.
- **Friend Removal:** Unfriend users when a relationship is no longer needed.
- **Friendship-Enforced Commitments:** Promises can only be created for accepted friends.
- **Backend Authorization:** Friendship relationships and search privacy are strictly verified on the server.

### Promises
- **Create Promise:** Create new commitments specifying title, recipient friend, optional description, due date, and optional due time.
- **PostgreSQL Persistence:** All promises are persisted in PostgreSQL via Serverpod ORM.
- **Home Dashboard:** Clean Material 3 dashboard displaying active, pending, and completed promises with pull-to-refresh capabilities.
- **Promise Details View:** Comprehensive view displaying promise schedule, participants, current status, and full activity history.

### Activity Tracking
- **Chronological Timeline:** Full history log tracking creation events, progress updates, status changes, and completion confirmations.
- **Progress Updates:** Participants can log updates with custom messages and individual activity statuses.
- **Independent Activity Statuses:** Activity statuses (`Pending`, `In Progress`, `Completed`) remain independent of the overall Promise status.
- **Full-Screen Activity Interface:** Dedicated `AddUpdateScreen` route preventing modal overlay collision or navigation issues.

### Promise Status Flow

```text
Pending ──> In Progress ──> Awaiting Confirmation ──> Completed
```

- **Two-Party Confirmation Rule:** Both the Creator and Recipient must confirm completion.
- **Awaiting Confirmation:** When one party confirms, the Promise enters `Awaiting Confirmation`.
- **Terminal Completed State:** When the second party confirms, the Promise transitions to `Completed`.
- **Read-Only Finality:** Once `Completed`, a Promise becomes strictly read-only. Updates, confirmations, status changes, and change requests are permanently blocked.
- **Server-Enforced Rules:** Business logic and status transitions are validated server-side.

### Request Changes
- **Participant Change Requests:** Either participant can request changes before final completion.
- **Reset Confirmations:** Submitting a change request resets any existing confirmations and returns the Promise status to `In Progress`.
- **Activity History:** Change request reasons are recorded into the promise's activity timeline.

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
 ├── Progress Updates
 ├── Status Tracking
 ├── Activity History
 ├── Confirm Completion
 └── Request Changes
        ↓
 Two-Party Confirmation
        ↓
    Completed (Final & Read-Only)
```

1. **Sign In:** User registers or logs in with email verification.
2. **Connect:** Search for friends and accept friend requests.
3. **Commit:** Create a Promise for an accepted friend.
4. **Track:** Log progress updates and change status as work progresses.
5. **Confirm:** Creator and Recipient both confirm completion.
6. **Finalize:** Promise enters the terminal `Completed` state once both parties have confirmed.

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
- **Email Delivery:** Brevo SMTP (`mailer` package)
- **Session Management:** `FlutterAuthSessionManager`

### Tools & AI
- **IDE & Development:** Android Studio
- **Version Control:** Git & GitHub
- **AI Coding Assistance:** Google Gemini & ChatGPT

---

## Architecture

```text
Flutter Android App
        ↓
promise_client (Generated Client Protocol)
        ↓
Serverpod Backend (promise_server)
        ↓
PostgreSQL Database
```

### Authentication & Transactional Email Architecture

```text
Flutter App
   ↓
Serverpod Email IDP
   ↓
Brevo SMTP (smtp-relay.brevo.com:587)
   ↓
User Email Inbox
```

> **Security Guarantee:** Brevo SMTP credentials and API keys remain strictly on the Serverpod backend inside `config/passwords.yaml` and are never exposed to the Flutter client.

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
- **`promise_server`**: Serverpod backend containing business logic, endpoints, data models (`.spy.yaml`), Brevo email service, and database migrations.
- **`promise_client`**: Automatically generated Dart client library imported by the Flutter application.
- **`promise_flutter`**: Flutter client application featuring Material 3 UI screens, state management, and Serverpod client integration.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started/sdk)
- [Serverpod CLI 4.0.3](https://docs.serverpod.dev/) (`dart pub global activate serverpod_cli`)
- [Docker Desktop](https://www.docker.com/) (for PostgreSQL database)
- Android Studio / Android Emulator

### 1. Start Serverpod Backend (Windows PowerShell)

```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_server
serverpod start --no-flutter
```

### 2. Run Flutter App on Android Emulator

In a separate terminal window:

```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_flutter
flutter pub get

flutter run -d emulator-5554 --no-dds `
  --dart-define=SERVER_URL=http://10.0.2.2:8080/
```

> **Notes:**
> - `http://10.0.2.2:8080/` is used by the Android emulator to reach `localhost` on the host development machine.
> - Physical Android devices require the host computer's local LAN IP address instead.
> - Production deployment will target a public Serverpod server URL.

---

## Brevo Email Configuration

Promise uses Brevo SMTP for transactional emails, including registration codes and password resets.

Configuration is defined server-side in `promise_server/config/passwords.yaml`:

```yaml
development:
  brevoSmtpHost: 'smtp-relay.brevo.com'
  brevoSmtpPort: '587'
  brevoSmtpUsername: 'YOUR_BREVO_SMTP_LOGIN'
  brevoSmtpKey: 'YOUR_BREVO_SMTP_KEY'
  brevoSenderEmail: 'YOUR_VERIFIED_SENDER_EMAIL'
  brevoSenderName: 'Promise'
```

### Brevo Security Checklist:
- **NEVER** commit `passwords.yaml` or secrets to Git (`.gitignore` protects this file).
- **NEVER** put Brevo credentials or SMTP keys inside the Flutter frontend app.
- Ensure the sender email is verified in your Brevo account dashboard.
- The Brevo SMTP key is distinct from the Brevo REST API key.

---

## Authentication UX

Promise translates backend authentication exceptions into clean, human-readable user messages:

| Scenario | User Message |
| :--- | :--- |
| **Wrong Credentials** | *"Incorrect email or password."* |
| **Unregistered Email Reset** | *"No account found with this email address."* |
| **Invalid Code** | *"That verification code is incorrect. Please try again."* |
| **Expired Code** | *"That verification code has expired. Please request a new code."* |
| **Disposable Email** | *"This email provider is not supported. Please use a permanent email address."* |
| **SMTP Delivery Failure** | *"We couldn't send the verification email. Please try again."* |
| **Network Error** | *"Unable to connect to Promise. Please check your connection and try again."* |

No raw exceptions, SQL errors, or internal stack traces are shown to the user.

---

## Development Commands

### Serverpod Backend (`promise_server`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_server

# Regenerate client and server code after changing .spy.yaml models
serverpod generate

# Code formatting and static analysis
dart format .
dart analyze

# Run backend unit and integration tests
dart test
```

### Flutter Frontend (`promise_flutter`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_flutter

# Code formatting and static analysis
dart format .
dart analyze

# Clean build cache and restore packages
flutter clean
flutter pub get
```

---

## Testing & Verification

### Automated Tests (`dart test`)
- [x] Serverpod server initialization and protocol generation.
- [x] Disposable email validator unit tests (`disposable_email_validator_test.dart`).
- [x] Email IDP endpoint integration tests (`email_idp_endpoint_test.dart`).
- [x] Database migrations and model serialization tests.

### Manual Verification (Android Emulator)
- [x] **Registration Flow:** Brevo transactional email code delivery to real inbox and code verification.
- [x] **Login Verification:** Success on correct credentials; error SnackBar on incorrect password.
- [x] **Password Reset:** Real email delivery for registered accounts; clear error for unregistered emails.
- [x] **Disposable Email Protection:** Rejection of temporary email providers (e.g., Mailinator).
- [x] **Friend System:** Searching users, sending friend requests, accepting/rejecting requests, and unfriending.
- [x] **Promise Lifecycle:** Creating promises for accepted friends, logging progress updates, requesting changes, and two-party completion.
- [x] **Terminal State Enforcement:** Confirmed promises become read-only and block further edits.
- [x] **Persistence:** Full state restoration across app restarts via PostgreSQL and `FlutterAuthSessionManager`.

---

## AI-Assisted Development

Promise was developed with AI-assisted engineering tools (Google Gemini) for:
- Architecture planning and database model design (`.spy.yaml`).
- Serverpod endpoint and Flutter screen code generation.
- Real-time debugging, linting, and refactoring.
- Material 3 UI design and full-screen navigation routing.
- Test planning and authentication error handling implementation.

All AI-generated code was reviewed, validated, and tested on Android emulator builds.

---

## Current Limitations

- **Local Server Default:** Development build defaults to local host Serverpod (`10.0.2.2:8080`). Production deployment requires pointing `SERVER_URL` to a deployed Serverpod instance.
- **Push Notifications:** Reminders and push notifications are planned for future releases.
- **File Attachments:** Promise evidence/photo uploads are planned, not yet implemented.
- **User Search Scale:** User search checks a bounded set of profiles appropriate for MVP scale.

---

## Status

Promise is a full-stack Serverpod 4.0 + Flutter MVP application. All core features — email authentication with Brevo SMTP, friend management, promise creation, progress tracking, two-party completion, and PostgreSQL persistence — are implemented and verified.

**Repository:** [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
