# Changelog

All notable changes to the Promise project will be documented in this file.

## v0.5.0 — Financial Tracking, Mobile UX & Auth Privacy/Email Integration

### Added
- **Shared Currency Package (`promise_currency`):** Created pure-Dart sibling package containing `IsoCurrencyCatalogue` (backed by SIX / ISO 4217 Table A.1 dataset) and `CurrencyUtils` exact minor-unit parser/formatter supporting all active, official currencies (0, 2, 3 decimal precision) without floating-point math or rounding drift.
- **Financial Terms (`PromiseFinancialTerms`):** Optional financial terms for 1-on-1 commitments and child milestones specifying agreed total, currency, and Payer/Payee participant roles. Creator-only mutation permissions. Terms become strictly read-only once payment/refund records exist.
- **Installment Payment Schedules (`PromisePaymentSchedule`):** Planned payment schedule entries with sequence order, amounts, due dates, and cancellation metadata (`cancelledAt`, `cancelledByUserId`, `cancellationReason`).
- **Offline Payment & Refund Recording (`PromisePaymentRecord`):** Log external payments and refunds (`recordKind: 'payment'` vs `'refund'`). Refunds inherit `scheduleId` and `currency` from the original payment and enforce a strict refund ceiling ($\sum \text{confirmedRefunds} \le \text{originalPayment}$) protected by PostgreSQL row locking (`SELECT id FROM promise_payment_record ... FOR UPDATE`).
- **Unified Two-Party Confirmation & Dispute:** RPC endpoints (`confirmPaymentRecord` / `disputePaymentRecord`) for payments and refunds. Enforces anti-self-confirmation and anti-self-dispute (`confirmerUserId != recorderUserId`).
- **Permanent Immutability of Confirmed Records:** Confirmed payment and refund records are permanently immutable. Post-confirmation offline challenges are logged via separate audited offline refunds (`recordKind: 'refund'`).
- **Two-Dimensional Financial Summaries (`PromiseFinancialSummary`):** Differentiates current net settlement progress (`settlementStatus`: `none`, `unpaid`, `partially_paid`, `paid`, `overpaid`) from refund history (`refundStatus`: `none`, `partially_refunded`, `fully_refunded`) and exposes an independent `hasActiveDispute` indicator.
- **Multi-Currency Parent Project Overviews (`GroupFinancialSummary`):** Group parent containers display aggregate totals grouped separately by currency without currency conversion or double-counting, while maintaining strict sibling milestone isolation.
- **Mobile-First Flutter UI & Searchable Currency Picker:**
  - Searchable `CurrencyPickerModal` bottom sheet.
  - `SetFinancialTermsDialog`, `RecordPaymentDialog`, `DisputeRecordDialog`.
  - Embedded `FinancialSection` on `PromiseDetailsScreen` with progress bar, status badges, active dispute warning banner, installment schedule checklist, and payment/refund history cards with role-aware action buttons.
  - Mobile responsive layouts verified across 320px, 360px, 390px, and 430px logical viewports with 1.3x system text scaling.
- **Root-Cause Clipboard Privacy Protection (`PromiseVerificationCodeInput`):** Custom OTP input
  widget passing `onClipboardFound: null` to Pinput, 100% eliminating automatic background clipboard
  reads on screen load, focus, or rebuild. Provides an explicit, user-triggered **"Paste Code from
  Clipboard"** button.
- **Brevo Email Delivery Validation & Logging:** Pre-flight configuration validation in
  `BrevoEmailService` ensuring `brevoApiKey` and `brevoSenderEmail` are configured before network
  requests. Rejects placeholder domains (`example.com`). Extracts Brevo's unique `messageId` for
  delivery tracking and maps errors safely to `BrevoDeliveryError`.

### Improved
- **Global Mobile UX & Accessibility:** Material 3 design system with $48\text{px}+$ touch targets, high-contrast badges, card borders (`outlineVariant`), rounded input decorations, and full responsive wrapping across narrow viewports.

### Security & Integrity
- **PostgreSQL Row-Level Locking:** Serialized concurrent refund requests using `SELECT ... FOR UPDATE` row locks inside PostgreSQL transactions, preventing race conditions or over-refunding beyond original payment amounts.
- **Strict Sibling Milestone Isolation:** Child recipients can only access financial terms and records for their assigned child commitment. Sibling sub-tasks remain strictly private.

## v0.4.0 — Core Model Evolution

### Added
- **Commitment Types:** Introduced explicit `commitmentType` classification (`Personal`, `Freelance`, `Team`) across database models, Serverpod RPC endpoints, and Flutter UI.
- **Project Milestone Sequencing:** Added optional `milestoneOrder` sequence numbering for group child commitments with deterministic sorting (explicit sequence number ascending, with `dueDate` ascending fallback).
- **Read-Only Parent Metadata Endpoint:** Created `getParentProjectMetadata` endpoint returning read-only `ParentProjectMetadata` for group parents, granting parent project context to assigned freelancers/child recipients while maintaining strict sibling-task isolation.
- **Dashboard Type Filtering:** Added `All`, `Personal`, `Freelance`, and `Team` filter chips to the Flutter Dashboard.

### Improved
- **Group Recipient Flexibility:** Updated `createGroupedPromise` recipient validation to allow assigning multiple child commitments/milestones to the same accepted recipient friend.
- **Parent Status Lifecycle Reliability:** Fixed parent status recalculation on child promise expiry (`PromiseLifecycleHelper.updateParentStatusIfNeeded`), ensuring parent status updates inside the cleanup transaction when unaccepted child commitments expire after 7 days.
- **Deterministic Legacy Fallbacks:** Established a unified legacy classification policy: 1-on-1 commitments default to `Personal`, legacy group parents default to `Team`, and child sub-tasks inherit their parent project's commitment type.

### Security
- **Strict Endpoint Authorization:** Restricted full parent `Promise` DB entity retrieval (`getPromise`) to direct participants (`_isDirectParticipant`). Child recipients receive read-only parent project metadata via `getParentProjectMetadata` without gaining access to parent/sibling activities or attachments.
- **Transactional Friendship Concurrency Hardening:** Enforced isolated database transaction boundaries with PostgreSQL advisory locks (`pg_advisory_xact_lock`) and `FOR UPDATE` row locks across friend endpoint operations, preventing duplicate or conflicting relationship records under concurrent requests.
