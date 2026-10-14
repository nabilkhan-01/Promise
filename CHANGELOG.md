# Changelog

All notable changes to the Promise project will be documented in this file.

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
