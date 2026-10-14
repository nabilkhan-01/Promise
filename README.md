# Promise (v0.5.0)

Promise helps people turn everyday agreements into clear, trackable, and documented commitments.

Whether delivering a project, submitting an assignment, completing a milestone, or confirming payment and completion between two parties, Promise provides a reliable way to keep track of everyday commitments from creation to final two-sided confirmation.

Promise is built around two fundamental rules:
1. **Work completion is not officially recognized until both sides confirm it.**
2. **Promise records offline financial payments and refunds; it does not process or transfer money.**

---

## What's New in v0.5.0

Version 0.5.0 introduces optional financial tracking and an enhanced mobile-first user experience:

- **Dedicated `promise_currency` Package:** Pure-Dart shared package containing the authoritative SIX / ISO 4217 Table A.1 dataset (`IsoCurrencyCatalogue`) and exact string-to-minor-unit parser/formatter (`CurrencyUtils`). Supports all worldwide active currencies (0, 2, and 3 minor-unit decimal precision) without floating-point math or rounding drift.
- **Optional Financial Terms:** Configure agreed contract totals, active ISO 4217 currencies, and Payer/Payee roles for 1-on-1 commitments or individual child milestones. Terms become strictly read-only once payment or refund records exist.
- **Installment Schedules:** Multi-installment schedule entries (`PromisePaymentSchedule`) with sequence order, amounts, due dates, and cancellation audit metadata (`cancelledAt`, `cancelledByUserId`, `cancellationReason`).
- **Offline Payment & Refund Recording:** Log external payments and refunds (`PromisePaymentRecord`). Refunds inherit `scheduleId` and `currency` from the original payment and enforce a strict refund ceiling ($\sum \text{confirmedRefunds} \le \text{originalPayment}$) protected by PostgreSQL row locking (`SELECT id FROM promise_payment_record ... FOR UPDATE`).
- **Unified Two-Party Confirmation & Dispute:** Unified confirmation (`confirmPaymentRecord`) and dispute (`disputePaymentRecord`) endpoints with strict anti-self-confirmation and anti-self-dispute rules (`confirmerUserId != recorderUserId`).
- **Permanent Immutability of Confirmed Records:** Confirmed payment and refund records are permanently immutable. Post-confirmation offline challenges are logged via separate audited offline refunds (`recordKind: 'refund'`).
- **Two-Dimensional Financial Summary Engine:**
  - **Settlement Progress (`settlementStatus`):** `none`, `unpaid`, `partially_paid`, `paid`, `overpaid` derived from net confirmed settlement ($\text{payments} - \text{refunds}$).
  - **Refund History (`refundStatus`):** `none`, `partially_refunded`, `fully_refunded` preserving past payment history even when net settlement drops to 0.
  - **Active Dispute Indicator (`hasActiveDispute`):** Independent boolean flag highlighting pending disputes without altering numeric ledger totals.
- **Multi-Currency Parent Project Overviews:** Group parent containers display aggregate totals grouped separately by currency (`GroupFinancialSummary`) without currency conversion or double-counting. Sibling child milestones remain strictly isolated.
- **Mobile-First Flutter UX:**
  - Searchable `CurrencyPickerModal` bottom sheet modal.
  - `SetFinancialTermsDialog` and `RecordPaymentDialog` with private evidence receipt attachment support via `AttachmentEndpoint`.
  - Embedded `FinancialSection` on `PromiseDetailsScreen` with progress bar, status badges, active dispute warning banner, installment schedule checklist, and payment/refund history cards with role-aware action buttons.
  - Responsive layouts verified across 320px, 360px, 390px, and 430px logical viewports with 1.3x system text scaling.

---

## Features

### App Launcher Branding
- **Handshake Launcher Icon:** Custom handshake branding logo replacing standard default icons across all Android mipmap densities (`hdpi`, `mdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) and iOS app icon sets.
- **Adaptive Icon Styling:** Configured with a near-black background (`#121318`) and safe-zone padding to maintain logo visibility under circular, squircle, or rounded Android icon masking.
- **App Name:** Displayed as **Promise** on the Android and iOS launcher screens.

### Authentication & Email Delivery
- **Serverpod Auth Email IDP:** Email authentication managed by Serverpod Auth 4.0.
- **Brevo REST API Email Delivery:** Transactional emails (registration and password resets) delivered via Brevo's HTTPS REST API (`POST https://api.brevo.com/v3/smtp/email`) on port 443.
- **Reliable Duplicate-Account Signup Fix:** Pre-registration RPC check (`checkEmailRegistration`) and race-condition fallback that detects existing registered accounts before registration is initiated. Displays *"An account with this email already exists. Please sign in instead."* with a direct **Sign In** action preserving the entered email address, preventing duplicate registration requests or unnecessary verification emails.
- **Server-Side Credentials:** Brevo API keys (`brevoApiKey`) are stored exclusively in Serverpod Cloud secrets / `config/passwords.yaml` and are never exposed to the Flutter client.
- **Password Reset Flow:** Complete email-verified password reset with secure 6-digit code verification.
- **Disposable Email Protection:** Authoritative server-side and client-side validation rejecting temporary/disposable email domain providers (e.g., Mailinator, TempMail).
- **Session Persistence & Sign Out:** Authenticated user sessions persist automatically across app restarts via `FlutterAuthSessionManager`.

### Friends System
- **User Search & Friend Requests:** Search registered users by email or username, send/view/accept/reject friend requests, and remove friendships.
- **Friendship-Enforced Commitments:** Promises can only be created for accepted friends.
- **Backend Authorization & Concurrency Safety:** Friendship relationships are enforced on the server within isolated database transactions protected by canonical PostgreSQL advisory locking (`pg_advisory_xact_lock`) and `FOR UPDATE` row locks.

### Promise Management, Commitment Types & Milestones
- **Unified Commitment Classification:** Explicit `commitmentType` support for `Personal` (1-on-1 favors/tasks), `Freelance` (client/contractor agreements), and `Team` (multi-member group projects) with interactive filter chips on the main Dashboard.
- **Project Milestone Sequence Ordering:** Optional `milestoneOrder` sequence numbering ($1, 2, 3...$) for child sub-tasks under group parent promises.
- **Read-Only Parent Metadata Endpoint:** Security-hardened `getParentProjectMetadata` RPC endpoint allowing assigned child recipients to view parent project context without exposing sibling activities, attachments, or financial records.
- **Strict Participant Authorization & Sibling Isolation:** Enforces strict caller checks (`_isDirectParticipant`) so child recipients can only access their assigned sub-tasks. Sibling sub-tasks and financial records remain strictly isolated.
- **Recipient Acceptance Workflow:** Newly created promises start in an unaccepted state (`recipientAccepted: false`). Assigned recipients must accept the invitation before work or financial operations can proceed.
- **7-Day Invitation Expiry & Status Recalculation:** Unaccepted promise invitations automatically expire after 7 days via Serverpod FutureCalls (`PromiseExpiryFutureCall`).
- **Timezone-Safe Deadlines:** Date-only deadlines are saved as UTC midnight (`DateTime.utc`) to prevent calendar date shifts across global timezones.

### Receipts & Private File Attachments
- **Serverpod Private Storage:** Attach documents (PDFs) or images (PNG, JPEG) up to 10 MB per file to commitments or payment records.
- **Authorized Uploads & Downloads:** Temporary 15-minute download URLs are strictly restricted to authorized participants.
- **Upload Progress UI:** Step-by-step progress feedback with linear progress indicators.
- **Cross-Party Review:** Non-uploading participants can approve or reject submitted receipts.

### Persistent In-App Notifications & Scheduled Reminders
- **Serverpod + PostgreSQL Notifications:** Full in-app notification engine with persistent database storage (`AppNotification`).
- **Event-Driven Notifications:** Triggered automatically on friends, promise updates, and financial activity (payment recorded, confirmed, disputed).
- **Deduplicated Deadline Reminders:** Scheduled via Serverpod FutureCalls (`DeadlineReminderFutureCall`) 24 hours prior to effective deadlines.
- **`NotificationsScreen`:** Mobile-first screen grouped by `TODAY` and `EARLIER` with unread emphasis, relative timestamps (`5m ago`), "Mark all as read", and tap-to-navigate directly to the referenced Promise or Friend Request.

### Activity Timeline & Status Tracking
- **Chronological Timeline:** Log tracking creation events, progress updates, status changes, change requests, financial activity, and completion confirmations.
- **Progress Updates:** Log updates with custom messages and individual activity statuses via the full-screen `AddUpdateScreen`.
- **Two-Party Completion Rule:** First party confirmation transitions overall status to `Awaiting Confirmation`. Second party confirmation transitions overall status to `Completed`.
- **Terminal Completed State:** Once both parties confirm, a Promise enters `Completed` status and becomes strictly read-only.

---

## Tech Stack

### Frontend
- **Framework:** Flutter `3.29+` (Mobile-first cross-platform UI)
- **Language:** Dart
- **Design System:** Material 3 with Inter typography

### Shared Packages
- **`promise_currency`:** Pure-Dart ISO 4217 currency catalogue and exact minor-unit arithmetic engine.

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

### Shared Currency Package (`promise_currency`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_currency
dart format .
dart analyze
dart test
```

### Serverpod Backend (`promise_server`)
```powershell
cd D:\GITHUB_REPOS\PROMISE\promise_server

# Regenerate protocol code after modifying .spy.yaml models
serverpod generate

# Format code and run static analysis
dart format .
dart analyze

# Run backend unit and integration tests (including financial & concurrency tests)
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

### Automated Shared Currency Tests (`promise_currency`)
- [x] ISO 4217 catalogue validation, non-empty codes, and search filters (`currency_test.dart`).
- [x] Exact minor-unit parsing without floating-point math (`0`, `2`, `3` decimal precision).
- [x] All `promise_currency` tests passing (**14 / 14** tests).

### Automated Backend Tests (`promise_server` - `dart test -j 1`)
- [x] Attachment endpoint security & upload integration tests (`attachment_endpoint_test.dart`).
- [x] Email IDP registration duplicate pre-checks (`email_idp_registration_test.dart`).
- [x] Financial models & ORM schema tests (`financial_models_test.dart`).
- [x] Financial RPC endpoint authorization, terms lock, refund ceiling, anti-self-confirmation, and 100% refund state tests (`financial_endpoint_test.dart`).
- [x] Real PostgreSQL row-locking concurrency tests (`financial_concurrency_test.dart`).
- [x] Friend endpoint concurrency with advisory locks (`friend_endpoint_test.dart`).
- [x] All server integration tests passing (**81 / 81** tests).

### Automated Flutter Tests (`promise_flutter` - `flutter test`)
- [x] Timezone-safe deadline rendering tests (`deadline_utils_test.dart`).
- [x] Sign-in & email auth flow tests (`sign_in_screen_test.dart`).
- [x] `IndicatorIconButton` widget tests (`indicator_icon_button_test.dart`).
- [x] Mobile responsive layout tests across 320px, 360px, 390px, 430px viewports & 1.3x text scaling (`responsive_screens_test.dart`).
- [x] Financial Section UI tests, minor-unit formatting, dispute banners, and searchable currency picker (`financial_section_test.dart`).
- [x] All Flutter widget/unit tests passing (**35 / 35** tests).

### Static Analysis
- [x] `promise_currency`: Clean (**0 issues**).
- [x] `promise_client`: Clean (**0 issues**).
- [x] `promise_server`: Clean (**0 issues**).
- [x] `promise_flutter`: Clean (**0 issues**).

---

## Status

Promise v0.5.0 is complete. All features — shared currency package, financial terms, payment schedules, offline payment/refund recording, two-party confirmation/dispute resolution, two-dimensional financial summaries, multi-currency parent project overviews, searchable currency picker, mobile-first responsive Flutter UI, and persistent in-app notifications — are implemented, verified, and passing all automated test suites across the monorepo workspace.

**Repository:** [https://github.com/nabilkhan-01/Promise](https://github.com/nabilkhan-01/Promise)
