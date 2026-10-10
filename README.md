# Promise (v0.3.0)

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

Promise is built around a fundamental rule: **a commitment is not officially complete until both sides confirm it.**

---

## Why Promise?

Every day, people make informal agreements — "I'll review your code by tomorrow," "I'll submit the report on Friday," or "I'll return the equipment by noon." Without a dedicated framework, these verbal or chat-based agreements lack structure, clear deadlines, progress tracking, and mutually acknowledged completion.

Promise solves this problem by turning everyday agreements into structured commitments with:
- **Verified Participants:** Agreements made between accepted friends.
- **Recipient Acceptance:** Recipient must explicitly accept an invitation before progress tracking begins.
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

### Promise Management & Recipient Acceptance
- **Recipient Acceptance Workflow:** Newly created promises start in an unaccepted state (`recipientAccepted: false`). The assigned recipient must explicitly accept the invitation before work operations (progress updates, completion confirmations, change requests, evidence uploads) can proceed.
- **7-Day Invitation Expiry:** Unaccepted promise invitations automatically expire after 7 days via Serverpod FutureCalls (`PromiseExpiryFutureCall`). Expired invitations, activities, cloud storage objects, and recipient notifications are safely cleaned up.
- **Create Promise:** Log new commitments specifying title, recipient friend, optional description, timezone-safe due date, and optional due time.
- **Nested Group Promises:** Create parent container commitments with up to 10 sub-tasks assigned to different accepted friends in a single atomic database transaction.
- **Derived Parent Progress:** Parent status is automatically derived from its children (`pending` -> `in_progress` -> `completed` when all children are finished). Direct manual status overrides or completion on parents are strictly blocked.
- **Timezone-Safe Deadlines:** Date-only deadlines are saved as UTC midnight (`DateTime.utc`) to prevent calendar date shifts across global timezones. Legacy records maintain backward-compatible local time rendering.
- **Tabbed Dashboard:** Clean Material 3 dashboard organized into two sections:
  - **Current (`pending`, `in_progress`, `awaiting_confirmation`):** Sorted strictly by nearest due date and due time first, with visual indicators (`Overdue by X days`, `Due today`, `Due tomorrow`, `Due Oct 14`, `Awaiting acceptance`).
  - **Completed (`completed`):** Archived commitments sorted newest first.
- **Participant Authorization:** Serverpod backend verifies caller identity against creator and recipient IDs for all operations.

### Receipts & Private File Attachments
- **Serverpod Private Storage:** Attach documents (PDFs) or images (PNG, JPEG) up to 10 MB per file.
- **Authorized Uploads & Downloads:** Upload descriptions and 15-minute temporary download URLs are strictly restricted to authorized Promise participants.
- **Upload Progress & UI Component:** Step-by-step progress feedback (`Preparing upload...` -> `Uploading {file}...` -> `Verifying attachment...` -> `Upload complete`) with linear progress indicators.
- **Reusable `IndicatorIconButton` Component:** Null-safe, animated Material 3 button component (`promise_flutter/lib/widgets/indicator_icon_button.dart`) with smooth `AnimatedSwitcher` transitions between normal, loading spinner, and success checkmark states.
- **Cross-Party Review:** Non-uploading participants can approve or reject submitted receipts with optional rejection reasons.
- **Preserved History:** Uploading a replacement receipt creates a new record while keeping previous review history intact for auditing.

### Persistent In-App Notifications & Scheduled Reminders
- **Serverpod + PostgreSQL Notifications:** Full in-app notification engine with persistent database storage (`AppNotification`).
- **Event-Driven Notifications:** Triggered automatically on key events:
  - **Friends:** `friend_request`, `friend_request_accepted`
  - **Promises:** `promise_created`, `promise_updated`, `promise_status_changed`, `change_requested`, `confirmation_requested`, `promise_completed`
- **Deduplicated Deadline Reminders:** Scheduled via Serverpod FutureCalls (`DeadlineReminderFutureCall`) 24 hours prior to effective deadlines. Notification database deduplication guarantees exactly one reminder per participant per deadline, resisting server retries or duplicate executions.
- **Late Acceptance Handling:** Accepting a promise within 24 hours of its deadline triggers an immediate timezone-neutral deadline reminder (*"Deadline reminder: '$title' is approaching. Please check its due date."*).
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

---

## Tech Stack

### Frontend
- **Framework:** Flutter `0.3.0+3` (Android-first cross-platform UI)
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
dart test -j 1
```

### Flutter Frontend (`promise_flutter`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_flutter

# Format code and run static analysis
dart format .
dart analyze

# Run Flutter tests
flutter test
```

---

## Testing & Verification

### Automated Backend Tests (`dart test -j 1`)
- [x] Disposable email validator unit tests (`disposable_email_validator_test.dart`).
- [x] Email IDP endpoint integration tests (`email_idp_endpoint_test.dart`).
- [x] Email registration duplicate detection integration tests (`email_idp_registration_test.dart`).
- [x] Attachment endpoint security & upload integration tests (`attachment_endpoint_test.dart`).
- [x] Group promise atomic creation & derived lifecycle integration tests (`group_promise_test.dart`).
- [x] Promise acceptance, 7-day expiry, and deduplicated deadline reminder integration tests (`promise_acceptance_and_future_calls_test.dart`).
- [x] All server integration tests passing (**40 / 40** tests).

### Automated Flutter Tests (`flutter test`)
- [x] Timezone-safe deadline rendering and sorting tests (`deadline_utils_test.dart`).
- [x] `IndicatorIconButton` widget unit tests (`indicator_icon_button_test.dart`).
- [x] All Flutter tests passing (**13 / 13** tests).

### Static Analysis
- [x] `promise_server`: Clean (**0 issues**).
- [x] `promise_client`: Clean (**0 issues**).
- [x] `promise_flutter`: Clean (**0 issues**).

---

## Security & Known Limitations

- **Security & Authorization:** Strict participant-level authorization on all promises, activities, attachments, and notifications. Sibling isolation is enforced on Group Promises so recipients can only access their assigned sub-tasks.
- **7-Day Expiry & Reminders:** Background execution uses Serverpod FutureCalls verified via automated integration tests (`promise_acceptance_and_future_calls_test.dart`). Full production verification depends on Serverpod Cloud execution.
- **Physical Device & Cloud Storage:** Upload verification and file picking have been tested on local embedded storage; physical Android device testing against live cloud storage will be performed manually.
- **30-Day Attachment Pruning:** Automatic background cleanup of 30-day unreviewed attachments or orphaned files remains deferred (for post-hackathon) to avoid untested database cron jobs.
- **Malware Scanning:** File uploads validate 10 MB limits and MIME types (`pdf`, `png`, `jpeg`), but do not perform deep byte-level antivirus scanning.

---

## Status

Promise v0.3.0 is a full-stack Serverpod 4.0.3 + Flutter application. All core features — recipient acceptance, 7-day invitation expiry, deduplicated deadline reminders, duplicate-account detection, Brevo email authentication, friends, time-safe promises, grouped multi-recipient promises, private receipt attachments, `IndicatorIconButton` animated UI feedback, in-app notifications, and PostgreSQL persistence — are implemented, verified, and passing all automated test suites.

**Repository:** [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
