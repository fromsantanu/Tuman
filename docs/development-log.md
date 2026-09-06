# Development log

## Phase 21 — Backups and retention

- Added Administrator-only backup and retention controls with complete MySQL/MariaDB dump generation, gzip compression, atomic finalization, external-storage validation, and retention of old backup files.
- Added safe run history for backup and purge operations without persisting credentials, commands, or backup contents.
- Added previewable and confirmed purging of only old email-delivery and activity-log records. Every executed purge creates and verifies a fresh backup before deleting in bounded transactions.
- Added CLI runners designed for Windows Task Scheduler or cron; no hidden web scheduler was introduced.
- Backups explicitly include triggers, stored procedures/functions, and scheduled events, then verify that every database table/view and each visible trigger, routine, and event has a definition in the generated dump before finalizing it.

## Phase 21 — Communications

- Added teacher-to-student and student-to-teacher messaging, including individual and active-batch recipients.
- Added Announcement, Reminder, Warning, Urgent Action, and Official categories for Teacher messages; Student messages are always Official, with a subject, message body, and one optional validated attachment.
- Added inboxes, unread dashboard-navigation notifications, protected attachment downloads, and SMTP delivery logging when mail is enabled.

## Phase 20 — Batches

- Added teacher-owned course batches with objective, teacher/student responsibilities, terms, and fixed-monthly, instalment, or one-time billing.
- Added managed batch memberships for existing students and transactional enrolment of new students directly into a batch.
- Added one-screen batch draft invoice generation for every active member, while retaining normal invoice issuing and cancellation.
- Added batch/individual attendance identification and a student-facing My Batches screen.

## Phase 13 - Receipts and PDF exports

Added Teacher-owned payment details, currency-aware invoice PDF downloads, and payment receipt PDF exports. Invoice PDFs include the issued student's name and available address.

## Phase 14 - Email notifications (partial)

Added a Teacher-owned invoice notice and payment-reminder queue using `tmn_email_log`. SMTP delivery and receipt emails are not implemented yet.

## Phase 12 - Student Portal

Replaced the Student placeholder with read-only, student-scoped profile, attendance, invoice, invoice-detail, and payment-history screens.

## Phase 11 - Payments

Added Teacher payment recording, payment history, and voiding. Payment currency is inherited from the invoice and invoice status is recalculated transactionally.

## Phase 00 — Project specification and architecture

**Date:** 2026-09-01  
**Status:** Complete

### Completed work

- Inspected the repository and confirmed it is a new Tuman project.
- Recorded the proposed simple modular PHP project layout.
- Defined the application layers, roles, access boundaries, and security baseline.
- Produced an initial entity/relationship and financial-history design.
- Documented key decisions and decisions deliberately deferred to later phases.
- Added a Phase 00 README and documentation set.
- Established `tmn_` as the required prefix for all current and future database tables.

### Not implemented

- No PHP application pages or services.
- No database or migration files.
- No authentication, user management, or public website.
- No environment file containing secrets.

### Next recommended phase

Phase 03 — Authentication and authorization.

## Phase 02 — MySQL database

**Date:** 2026-09-02  
**Status:** Completed with environment issue

### Completed work

- Added `database/schema.sql` with 14 `tmn_` tables, foreign keys, indexes, unique keys, `utf8mb4`, and financial constraints.
- Added `database/seed.sql` with fictional development data and documented development-only credentials.
- Added `.env.example`, environment loading, a reusable PDO connection helper, and a connection check.
- Updated database installation and design documentation.

### Environment issue

The local MySQL service is running, but it rejects the standard blank-password root account. Schema execution and live connection verification await valid local credentials in an uncommitted `.env` file. The code reports this safely without exposing connection details.

## Phase 03 — Authentication and authorization

**Date:** 2026-09-02  
**Status:** Completed with environment limitation

### Implemented

- Added reusable secure session, CSRF, authentication, logout, current-user, and role-guard helpers.
- Added a CSRF-protected login form and POST-only CSRF-protected logout endpoint.
- Used the existing PDO helper and parameterized lookup of `tmn_users`; successful logins verify PHP password hashes, reject inactive accounts, regenerate the session ID, and update `last_login_at`.
- Added minimal role-protected Administrator, Teacher, and Student placeholders. They contain no business functionality.

### Tests and limitation

- PHP syntax checks and helper-level CSRF/session-regeneration/logout tests pass.
- Live login, user status, last-login, database query, and browser redirect tests remain blocked until valid MySQL credentials are placed in the uncommitted `.env` file.

### Next recommended phase

Phase 04 — Public website.

## Phase 04 — Public website

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Created responsive Home and About pages with consistent Tuman branding.
- Added shared public header/footer templates and a local CSS stylesheet.
- Integrated the existing login page with the shared public layout.
- Kept protected role placeholders out of public navigation and made no database changes.

### Tests

- Verified Home and About rendering and navigation in a local browser.
- Verified a 390px layout has no horizontal overflow and stacks the navigation/cards appropriately.
- Retained the existing database credential limitation for live login testing.

### Next recommended phase

Phase 05 — Administrator module.

## Phase 05 — Administrator module

**Date:** 2026-09-02  
**Status:** Completed with environment limitation

### Implemented

- Replaced the Administrator placeholder with protected user-management pages.
- Added user listing, creation, editing/role change, activation/deactivation, and password-reset workflows.
- Added reusable Administrator and activity-log services using PDO prepared statements.
- Protected every state-changing form with CSRF validation and every admin page with the `ADMIN` role guard.
- Added safeguards against self-deactivation, self-demotion, and removing the final active Administrator.

### Tests

- PHP syntax, Administrator validation, CSRF/session helper, and guard-presence checks pass.
- Live authentication, CRUD, audit-log, inactive-login, and final-active-Administrator tests pass with the configured separate MySQL database.

### Next recommended phase

Phase 06 — Teacher module.

## Phase 06 — Teacher module

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Added Teacher dashboard, student list, enrolment, view, edit, and assignment-deactivation pages.
- Added ownership-scoped Teacher student service and safe activity logging.
- Added transactional enrolment and profile-update workflows.
- Preserved student and assignment history through assignment deactivation rather than deletion.

### Tests

- Live database checks passed for Teacher ownership, enrolment, profile update, deactivation, rollback, and validation.
- All Teacher pages enforce the server-side `TEACHER` role guard, and unauthenticated access redirects to login.

### Next recommended phase

Phase 07 — Responsibilities.

## Database connectivity verification

**Date:** 2026-09-02  
The separate MySQL environment was configured and verified. All 14 `tmn_` tables and the fictional seed dataset are available. A transaction-scoped test account was rolled back and the seeded student used for status testing was restored to `ACTIVE`.

## Phase 07 — Responsibilities

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Added Teacher responsibility list, create, edit, and deactivation pages.
- Added an ownership-scoped responsibility service using the existing `tmn_responsibilities` table.
- Limited creation to active Teacher-student assignments and validated responsibility type, title, and effective dates on the server.
- Added CSRF protection to every state-changing form and concise activity logging for create, update, and deactivation.
- Retained responsibility history by changing status to `INACTIVE` rather than deleting rows.

### Tests

- PHP syntax checks passed for all Teacher pages.
- Live database verification passed for create, audit entry linkage, Teacher ownership, update, deactivation, validation rejection, cross-Teacher protection, and rollback cleanup.

### Next recommended phase

Phase 08 — Attendance.

## Phase 08 — Attendance

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Added Teacher attendance list, record, edit, and cancellation pages.
- Added an ownership-scoped attendance service using the existing `tmn_attendance` table.
- Enforced active assignments for new records, assignment-date bounds, allowed statuses, duplicate-session protection, and server-side duration calculation.
- Kept non-present and cancelled records time-free, and retained cancelled rows as history.
- Added CSRF protection and concise activity-log events for attendance creation, update, and status changes.

### Tests

- PHP syntax checks passed for all Teacher pages and the attendance service.
- Live database verification passed for duration calculation, non-present handling, validation, duplicate protection, ownership, update, cancellation history, and rollback cleanup.

### Next recommended phase

Phase 09 — Billing.

## Phase 09 — Billing Rules

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Added Teacher billing-rule list, create, edit, and end/deactivation pages.
- Added an ownership-scoped billing service using the existing `tmn_student_billing` table.
- Supported `HOURLY` and `FIXED_MONTHLY` rules with server-validated decimal rates and assignment-bound effective dates.
- Prevented overlapping active date ranges for the same assignment and billing mode with a transaction and locked active rows.
- Preserved billing history through inactive status and added concise activity-log entries for create, update, and status change.

### Tests

- PHP syntax checks passed for all Teacher pages and the billing service.
- Live database verification passed for both billing modes, rate validation, overlap rejection, non-overlapping/different-mode rules, ownership, update, history, audit events, and rollback cleanup.

### Next recommended phase

Phase 10 — Invoices.

## Phase 10 — Invoices

**Date:** 2026-09-02  
**Status:** Complete

### Implemented

- Added Teacher invoice list, monthly draft generation, read-only detail, issue, and draft-cancellation pages.
- Added an ownership-scoped invoice service using the existing `tmn_invoices`, `tmn_invoice_items`, and `tmn_invoice_sequences` tables.
- Generated immutable hourly session and fixed-monthly item snapshots using effective historical billing rules.
- Used integer minor-unit calculations and half-up rounding for quantities, item amounts, subtotals, and totals.
- Reserved global invoice numbers and created invoice header/items/audit records in one transaction.
- Enforced draft-only issue/cancellation transitions and retained all invoice history.

### Tests

- PHP syntax checks passed for the invoice service and all Teacher invoice pages.
- Live database verification passed for hourly/fixed generation, historical inactive rates, snapshots, sequence reservation, validation, ownership, state transitions, replacement after cancellation, audit events, and rollback cleanup.

### Next recommended phase

Phase 10A — International Students and Multi-Currency Support.
