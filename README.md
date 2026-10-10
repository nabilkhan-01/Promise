# Promise

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

Promise is built around a fundamental rule: **a commitment is not officially complete until both sides confirm it.**

---

## Why Promise?

Every day, people make informal agreements — "I'll review your code by tomorrow," "I'll submit the report on Friday," or "I'll return the equipment by noon." Without a dedicated framework, these verbal or chat-based agreements lack structure, clear deadlines, progress tracking, and mutually acknowledged completion.

Promise solves this problem by turning everyday agreements into structured commitments with:
- **Verified Participants:** Agreements made between accepted friends.
- **Clear Terms & Schedules:** Timezone-safe due dates and optional due times.
- **Chronological History:** Auditable timeline of progress updates and status changes.
- **Two-Party Confirmation:** Completion is only recognized when both Creator and Recipient confirm.
- **Documented Change Requests:** A formal mechanism to request and record changes if circumstances evolve.
- **Private Attachments & Receipts:** Attach evidence or receipts for cross-party approval.
- **Nested Group Promises:** Create parent commitments containing sub-tasks assigned to different friends.
- **Terminal Finality:** Completed commitments are archived as immutable, read-only records.

---

## Features

### Authentication & Email Delivery
- **Serverpod Auth Email IDP:** Email authentication managed by Serverpod Auth 4.0.
- **Brevo REST API Email Delivery:** Transactional emails (registration and password resets) delivered via Brevo's HTTPS REST API (`POST https://api.brevo.com/v3/smtp/email`) on port 443.
- **Duplicate-Account Detection:** Immediate server-side check during sign-up for existing registered accounts. Returns a clear error (*"An account with this email already exists. Please sign in instead."*) with a direct **Sign In** action preserving the entered email address, preventing duplicate registration requests or unnecessary verification emails.
- **Server-Side Credentials:** Brevo API keys (`brevoApiKey`) are stored exclusively in Serverpod Cloud secrets / `config/passwords.yaml` and are never exposed to the Flutter client.
- **Password Reset Flow:** Complete email-verified password reset with secure 6-digit code verification.
- **Disposable Email Protection:** Authoritative server-side and client-side validation rejecting temporary/disposable email domain providers (e.g., Mailinator, TempMail).
- **User-Facing Error Feedback:** Human-readable error feedback for invalid credentials, unregistered email reset requests, duplicate sign-ups, expired/incorrect verification codes, and network issues.
- **Session Persistence:** Authenticated user sessions persist automatically across app restarts via `FlutterAuthSessionManager`.
- **Sign Out:** Secure session token revocation and sign out.

### Friends System
- **User Search:** Search registered Promise users by email or username.
- **Friend Requests:** Send, view pending, accept, and reject friend requests.
- **Friend Removal:** Remove existing friendships when necessary.
- **Friendship-Enforced Commitments:** Promises can only be created for accepted friends.
- **Backend Authorization:** Friendship relationships and privacy rules are enforced on the server.

### Promise Management & Tabbed Dashboard
- **Create Promise:** Log new commitments specifying title, recipient friend, optional description, timezone-safe due date, and optional due time.
- **Nested Group Promises:** Create parent container commitments with up to 10 sub-tasks assigned to different accepted friends in a single atomic database transaction.
- **Derived Parent Progress:** Parent status is automatically derived from its children (`pending` -> `in_progress` -> `completed` when all children are finished). Direct manual status overrides or completion on parents are strictly blocked.
- **Timezone-Safe Deadlines:** Date-only deadlines are saved as UTC midnight (`DateTime.utc`) to prevent calendar date shifts across global timezones. Legacy records maintain backward-compatible local time rendering.
- **PostgreSQL Persistence:** All promises, activities, attachments, notifications, and friendships are persisted in PostgreSQL via Serverpod ORM.
- **Tabbed Dashboard:** Clean Material 3 dashboard organized into two sections:
  - **Current (`pending`, `in_progress`, `awaiting_confirmation`):** Sorted strictly by nearest due date and due time first, with visual indicators (`OVERDUE`, `DUE TODAY`, `UPCOMING`).
  - **Completed (`completed`):** Archived commitments sorted newest first.
  - Live section counts (e.g. `Current (2)`, `Completed (4)`) and custom empty state messages.
- **Participant Authorization:** Serverpod backend verifies caller identity against creator and recipient IDs for all operations.

### Receipts & Private File Attachments
- **Serverpod Private Storage:** Attach documents (PDFs) or images (PNG, JPEG) up to 10 MB per file.
- **Authorized Uploads & Downloads:** Upload descriptions and 15-minute temporary download URLs are strictly restricted to authorized Promise participants.
- **Cross-Party Review:** Non-uploading participants can approve or reject submitted receipts with optional rejection reasons.
- **Preserved History:** Uploading a replacement receipt creates a new record while keeping previous review history intact for auditing.

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
Create Promise / Group Promise
 ↓
Accepted Friend(s)
 ↓
Promise Details
 ├── Sub-Promises (for Group Parents)
 ├── Attachments & Evidence (PDF / Images with Approve / Reject Review)
 ├── Progress Updates (Pending / In Progress / Completed)
 ├── Status Tracking (Pending / In Progress / Awaiting Confirmation)
 ├── Activity History Timeline
 ├── Confirm Completion (Creator & Recipient)
 └── Request Changes (Resets Confirmations ──> In Progress)
        ↓
 Two-Party Confirmation / Aggregate Sub-Promise Completion
        ↓
    Completed (Terminal & Read-Only)
```

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
- **Cloud Storage:** Serverpod Cloud Storage (`serverpod_cloud_storage`)

### Authentication & Email
- **Identity Provider:** Serverpod Auth IDP (`serverpod_auth_idp_server`, `serverpod_auth_idp_flutter`)
- **Email Delivery:** Brevo Transactional Email REST API (`https://api.brevo.com/v3/smtp/email`)
- **Session Management:** `FlutterAuthSessionManager`

---

## User-Facing Error Messaging
Promise translates backend authentication and validation exceptions into friendly, actionable UI feedback:

| Scenario | User Message |
| :--- | :--- |
| **Existing Account Sign Up** | *"An account with this email already exists. Please sign in instead."* (with direct **Sign In** action) |
| **Wrong Credentials** | *"Incorrect email or password."* |
| **Unregistered Email Reset** | *"No account found with this email address."* |
| **Invalid Code** | *"That verification code is incorrect. Please try again."* |
| **Expired Code** | *"That verification code has expired. Please request a new code."* |
| **Disposable Email** | *"This email provider is not supported. Please use a permanent email address."* |
| **Delivery Failure** | *"We couldn't send the verification email. Please try again."* |
| **Network Error** | *"Unable to connect to Promise. Please check your connection and try again."* |

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

# Run Flutter tests
flutter test test/deadline_utils_test.dart
```

---

## Testing & Verification

### Automated Backend Tests (`dart test`)
- [x] Disposable email validator unit tests (`disposable_email_validator_test.dart`).
- [x] Email IDP endpoint integration tests (`email_idp_endpoint_test.dart`).
- [x] Email registration duplicate detection integration tests (`email_idp_registration_test.dart`).
- [x] Attachment endpoint security & upload integration tests (`attachment_endpoint_test.dart`).
- [x] Group promise atomic creation & derived lifecycle integration tests (`group_promise_test.dart`).
- [x] All server integration tests passing (`37/37` tests).

### Automated Flutter Tests (`flutter test`)
- [x] Timezone-safe deadline rendering and sorting tests (`deadline_utils_test.dart`).
- [x] All Flutter tests passing (`5/5` tests).

### Static Analysis
- [x] `promise_server`: Clean (`No issues found!`).
- [x] `promise_client`: Clean (`No issues found!`).
- [x] `promise_flutter`: Clean (`No issues found!`).

---

## Limitations & Deferred Features

- **30-Day Attachment Pruning:** Automatic background cleanup of 30-day unreviewed attachments or orphaned files remains deferred (for post-hackathon) to avoid untested database cron jobs.
- **Malware Scanning:** File uploads validate 10 MB limits and MIME types (`pdf`, `png`, `jpeg`), but do not perform deep byte-level antivirus scanning.
- **Push Notifications:** Reminders currently use persistent in-app notifications; FCM push notifications are planned for future releases.
- **Payment Gateway Integration:** Payment escrow and gateways are out of scope for the current MVP release.

---

## Status

Promise is a full-stack Serverpod 4.0 + Flutter application. All core features — duplicate-account detection, Brevo email authentication, friends, time-safe promises, grouped multi-recipient promises, private receipt attachments, in-app notifications, and PostgreSQL persistence — are implemented, verified, and passing all automated test suites.

**Repository:** [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
