# Initial database and entity design

## Status

Phase 10A adds optional `tmn_student_profiles.country_code` and `currency_code` columns on `tmn_student_billing`, `tmn_invoices`, and `tmn_payments`. Apply `database/migrations/20260902_phase_10a_international_currency.sql` to an existing database. It is idempotent; existing financial records retain their values and receive `INR`. Currency conversion is not performed.

This document describes the implemented Phase 02 schema. The source of truth is `database/schema.sql`; `database/seed.sql` provides fictional development-only data.

## Conventions

- Primary keys use `BIGINT UNSIGNED` auto-increment identifiers unless a later migration justifies another choice.
- Timestamps use `DATETIME`. Deployment must use one consistent application/database timezone policy; UTC is recommended for production.
- Currency values use `DECIMAL(12,2)`. Quantities and hours use `DECIMAL(10,2)` where fractional values are possible.
- Role, status, billing mode, attendance status, invoice status, payment method, and delivery status use MySQL `ENUM` values to reject unsupported values.
- Every foreign key is indexed. Important ownership and lookup paths receive composite indexes.
- All database table names must begin with the required `tmn_` prefix.

## Core identity tables

| Table | Purpose | Important fields and constraints |
| --- | --- | --- |
| `tmn_users` | One authentication account per person. | `id` PK; `username` unique; `password_hash`; `role` (administrator, teacher, student); `status` (active, inactive); `created_at`, `updated_at`, `last_login_at` nullable. |
| `tmn_teacher_profiles` | Teacher-specific details. | `user_id` PK/FK → `tmn_users.id`; name, email, phone, address fields as required. |
| `tmn_student_profiles` | Student-specific personal/contact details. | `user_id` PK/FK → `tmn_users.id`; name, email, phone, address fields as required; no billing or role fields. |
| `tmn_teacher_students` | Assignment and history between a teacher and a student. | `id` PK; `teacher_user_id` FK → `tmn_users.id`; `student_user_id` FK → `tmn_users.id`; `start_date`; `end_date` nullable; `status`; unique active assignment rule enforced by application/appropriate index strategy. Index `(teacher_user_id, status)` and `(student_user_id, status)`. |

Role/profile consistency is a business rule: a teacher profile belongs to a user whose role is `TEACHER`, and similarly for students. Application validation is preferred over database triggers so that the design remains understandable.

## Teaching records

| Table | Purpose | Important fields and constraints |
| --- | --- | --- |
| `tmn_responsibilities` | Structured teacher or student responsibilities assigned within a teacher–student relationship. | `id` PK; `teacher_student_id` FK; `responsibility_for` (teacher/student); `title`; `details` nullable; `status`; `effective_from`; `effective_to` nullable; timestamps. |
| `tmn_attendance` | A dated teaching session or attendance record. | `id` PK; `teacher_student_id` FK; `session_date`; `start_time` nullable; `end_time` nullable; `duration_minutes` nullable; `status` (present, absent, leave, cancelled, holiday); `remarks` nullable; timestamps. Index `(teacher_student_id, session_date)`, plus a uniqueness rule for non-null session start time. |
| `tmn_batches` | A teacher-owned group of students for one course. | `id` PK; `teacher_user_id` FK; unique teacher-local batch name; objective, responsibilities, terms; fixed-monthly, instalment, or one-time charge and currency; status; timestamps. |
| `tmn_batch_students` | Batch membership tied to the existing teacher-student assignment. | `id` PK; `batch_id` FK; `teacher_student_id` FK; enrolled-on date; status; timestamps. A student can have both batch and individual lesson records. |

`duration_minutes` is calculated by the application when valid start and end times are supplied for a present session. Absent, leave, cancelled, and holiday records use null start/end times and null duration. The assignment/date/start-time unique key permits multiple sessions on one date when each has a different start time.

## Billing and finance tables

| Table | Purpose | Important fields and constraints |
| --- | --- | --- |
| `tmn_student_billing` | Effective-dated billing rules for one assignment. | `id` PK; `teacher_student_id` FK; `billing_mode` (fixed_monthly/hourly); `rate` DECIMAL(12,2); `effective_from`; `effective_to` nullable; `status`; timestamps. Index `(teacher_student_id, effective_from)`. Overlapping active effective periods for the same mode must be rejected. |
| `tmn_invoice_sequences` | Safely reserves unique invoice sequence numbers. | `sequence_scope` PK; `current_value`; `updated_at`. Updated only within the invoice-creation transaction. |
| `tmn_invoices` | Invoice header and issued financial snapshot. | `id` PK; `invoice_number` unique; `teacher_user_id` FK; `student_user_id` FK; `teacher_student_id` FK; `billing_period_from`, `billing_period_to`; `invoice_date`; `due_date` nullable; `subtotal`, `discount_amount`, `total_amount` DECIMAL(12,2); `status` (draft, issued, partially_paid, paid, cancelled); timestamps. Index `(student_user_id, invoice_date)` and `(teacher_user_id, invoice_date)`. |
| `tmn_invoice_items` | Itemized immutable amounts for an invoice. | `id` PK; `invoice_id` FK; `description`; `quantity` DECIMAL(10,2); `unit_rate` DECIMAL(12,2); `amount` DECIMAL(12,2); `sort_order`. |
| `tmn_payments` | Payments recorded against invoices. | `id` PK; `invoice_id` FK; `teacher_user_id` FK; `student_user_id` FK; `payment_date`; `amount` DECIMAL(12,2); `payment_method`; `reference_number` nullable; `remarks` nullable; `status` (valid, voided); `voided_at` nullable; timestamps. Index `(invoice_id, status)` and `(student_user_id, payment_date)`. |

## Supporting tables

| Table | Purpose | Important fields and constraints |
| --- | --- | --- |
| `tmn_email_log` | Delivery attempts kept separate from page/business logic. | `id` PK; related entity type/id; recipient; subject; delivery status; provider response summary nullable; sent timestamp; created timestamp. No credentials or sensitive body data. |
| `tmn_teacher_payment_details` | Teacher-owned static payment instructions for invoice PDFs. | `teacher_user_id` PK/FK; separate Indian and international account/instruction fields; no values are written to activity logs. |
| `tmn_system_settings` | Small, administrator-controlled non-secret configuration values. | `setting_key` PK; `setting_value`; `updated_at`; `updated_by_user_id` nullable FK. Secrets are not stored here. |
| `tmn_activity_log` | Audit trail for meaningful actions. | `id` PK; `actor_user_id` nullable FK; `action`; `entity_type`; `entity_id` nullable; safe details JSON/text nullable; `created_at`. Index `(entity_type, entity_id)` and `(actor_user_id, created_at)`. |
| `tmn_backup_runs` | Metadata for complete database-backup attempts. | `id` PK; optional initiating Administrator; status; safe storage identifier; final size; safe error summary; start/completion times. No credentials, command text, or dump content is stored. |
| `tmn_purge_runs` | Metadata for retention previews and executions. | `id` PK; optional initiating Administrator; optional verified backup run; mode; cutoff date; status; per-table row counts; safe error summary; timestamps. |

## Relationships

```text
tmn_users ── 1:0..1 ── tmn_teacher_profiles
tmn_users ── 1:0..1 ── tmn_student_profiles
teacher user ── 1:* ── tmn_teacher_students ── *:1 ── student user
tmn_teacher_students ── 1:* ── tmn_responsibilities
tmn_teacher_students ── 1:* ── tmn_attendance
tmn_batches ── 1:* ── tmn_batch_students ── *:1 ── tmn_teacher_students
tmn_teacher_students ── 1:* ── tmn_student_billing
tmn_teacher_students ── 1:* ── tmn_invoices ── 1:* ── tmn_invoice_items
tmn_invoices ── 1:* ── tmn_payments
```

## Fundamental business rules

1. Only active users may authenticate.
2. A teacher action on a student must be scoped through an active `tmn_teacher_students` assignment belonging to that teacher.
3. A student action must be scoped through the logged-in student's own user ID.
4. An invoice is created only for a valid teacher–student assignment; its items preserve the rates used at generation time.
5. The sum of valid payments cannot exceed the invoice total unless a future overpayment feature is explicitly enabled.
6. Invoice status is derived or updated transactionally from valid payment totals. Cancelled invoices cannot accept new valid payments.
7. Financial records are retained. A payment error is voided with an audit trail, not deleted.
8. An active billing rule cannot ambiguously overlap another applicable rule for the same assignment and mode.
9. Attendance must be connected to the assignment rather than merely accepting unrelated teacher and student identifiers.
10. A batch attendance record may only use an active batch membership belonging to the teacher and valid on its session date. Batch invoice drafts use the batch charge; individual billing remains unchanged.

## Implemented constraints and delete behaviour

All tables use InnoDB with `utf8mb4_unicode_ci`. Most relationships use `ON DELETE RESTRICT`: users, assignments, invoices, and payments cannot be casually removed when related history exists. `tmn_system_settings.updated_by_user_id` and `tmn_activity_log.actor_user_id` use `ON DELETE SET NULL`, preserving the setting or audit entry if the associated user is eventually removed.

Unique constraints protect usernames, non-null email addresses, invoice numbers, and an attendance session identified by assignment, date, and start time. Check constraints reject negative financial values, invalid date ranges, and invalid attendance time ranges. Billing-period overlap and prevention of payment overpayment require transactional application checks in their later phases because they depend on ranges and aggregated amounts.

## Financial and history rules

### Phase 11-14 additions

`tmn_payments.currency_code` is copied from its invoice and valid-payment totals determine the invoice status. `tmn_teacher_payment_details` stores two optional, Teacher-owned payment instruction blocks. `tmn_email_log` is the Phase 14 outbox: `PENDING` means queued, not delivered. No email bodies, account numbers, passwords, or SMTP credentials are stored in the log.

Money is `DECIMAL(12,2)` and quantities are `DECIMAL(10,2)`; calculations must round to two decimal places deterministically. An invoice stores totals and each `tmn_invoice_items` row stores its own quantity, rate, and amount snapshot. Consequently a later billing-rate row cannot change an existing invoice. Invoice generation and payment recording must use transactions in later phases.

## Installation and seed data

1. Create `.env` by copying `.env.example` and set the MySQL connection values.
2. Execute `database/schema.sql` using a MySQL account that can create the `tuman` database.
3. Execute `database/seed.sql` against that database.
4. Run `php tests/database_connection.php`.

The seed supplies one administrator, two teachers, four students, assignments, responsibilities, billing examples, attendance, two invoices with items, and a partial payment. All accounts use the clearly development-only password `TumanDemo2026!`. Do not use these accounts or password in production.

## Phase 21 maintenance migration

Apply `database/migrations/20260905_phase_21_maintenance.sql` to an existing database before using backup or retention controls. It creates only the run-metadata tables. The backup itself is produced by the configured MySQL/MariaDB dump utility and includes the complete database schema and data.
