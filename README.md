# Tuman — Tuition Management System

Tuman is a planned PHP and MySQL application for individual tuition teachers and small tuition organisations. It will help administrators, teachers, and students manage enrolment, attendance, billing, invoices, and payments.

## Current status

**Phase 21 — Backups, retention, and communications** is complete. Administrators can create complete database backups and safely purge only old operational email and activity logs; Teachers and Students can exchange messages.

## Planned technology

- PHP 8.x
- MySQL 8.x or compatible MariaDB
- HTML, CSS, and small amounts of JavaScript where useful
- PDO with prepared statements
- PHP sessions and PHP password hashing

## Documentation

- [Architecture](docs/architecture.md)
- [Initial database design](docs/database.md)
- [Development log](docs/development-log.md)
- [Testing approach](docs/testing.md)
- [User manual outline](docs/user-manual.md)

## Database setup (development)

1. Copy `.env.example` to `.env` and enter MySQL credentials for a user that can create and use the `tuman` database.
2. Run `database/schema.sql` with that MySQL user.
3. Run `database/seed.sql` to load fictional development data.
4. Run `php tests/database_connection.php` to confirm the configured PHP PDO connection.

All database table names begin with `tmn_`. Seed accounts are development-only and share the password `TumanDemo2026!`.

## Authentication test pages

After database setup, open `/Tuman/public/login.php`. Successful login redirects an `ADMIN`, `TEACHER`, or `STUDENT` account to its protected placeholder. These pages exist only to verify Phase 03 access control; they are not the final dashboards.

## Public website

Open `/Tuman/public/index.php` for the public Home page or `/Tuman/public/about.php` to learn about the project. Public navigation offers Home, About, and Login only; protected role placeholders are not exposed through it.

## Administrator module

After signing in as an Administrator, open `/Tuman/admin/index.php`. The module supports listing, creating, editing, activating/deactivating, and password-resetting user accounts. It intentionally does not yet include Teacher or Student operational features.

## Teacher module

After signing in as a Teacher, open `/Tuman/teacher/index.php`. Teachers can view their own students, enrol a new student, update permitted profile details, and deactivate their own Teacher-student relationship without deleting history.

## Responsibilities module

Teachers can open `/Tuman/teacher/responsibilities.php` to add, edit, and deactivate structured Teacher or Student responsibilities. A responsibility is linked to one active Teacher-student assignment, has effective dates, and is retained as history when deactivated.

## Attendance module

Teachers can open `/Tuman/teacher/attendance.php` to record, edit, and cancel attendance sessions for their own students. Present sessions have server-calculated duration; absent, leave, holiday, and cancelled records have no timing data. Multiple sessions per day are supported when their start times differ.

## Billing Rules module

Teachers can open `/Tuman/teacher/billing.php` to add, edit, and end hourly or fixed-monthly billing rules for their own students. Active rules cannot overlap for the same student and billing mode; inactive rules are retained as history.

## Invoices module

Teachers can open `/Tuman/teacher/invoices.php` to generate one-calendar-month invoice drafts for their own students. Generated items, rates, quantities, and totals are immutable snapshots. Drafts can be issued or cancelled, downloaded as PDFs, and queued for email notification.

## Next step

Continue with future enhancements such as production readiness and additional communication workflows.

## Backups and retention

Administrators can open `/Tuman/admin/maintenance.php` to run a complete database backup, see recent backup history, preview old operational records, and purge eligible records. Backups are written to the external directory configured by `TUMAN_BACKUP_DIR`; this directory must not be inside the application or web root.

Only `tmn_email_log` and `tmn_activity_log` records before a selected cutoff are eligible for deletion. Financial, invoice, payment, credit, refund, user, attendance, teaching, batch, and billing history are retained. A real purge always creates and verifies a fresh backup first. Backups include the selected Tuman database's tables, data, views, triggers, stored procedures, functions, and scheduled events; server user accounts and grants are outside this database backup's scope.

Set `TUMAN_MYSQLDUMP_PATH`, `TUMAN_BACKUP_DIR`, `TUMAN_BACKUP_RETENTION_DAYS`, and `TUMAN_PURGE_RETENTION_DAYS` in `.env`. From the application directory, run `php bin/backup-database.php` for a backup; run `php bin/purge-retention.php --cutoff=YYYY-MM-DD --preview` to preview a purge; run `php bin/purge-retention.php --cutoff=YYYY-MM-DD --execute` to purge after a fresh backup. Schedule `php bin/backup-database.php` for backups and `php bin/purge-retention.php --scheduled` for retention purges using Windows Task Scheduler or cron.

## Reports module

Teachers can open `/Tuman/teacher/reports.php` to review income, refunds, outstanding invoices, transaction history, and summaries for their own students. Administrators can open `/Tuman/admin/reports.php` for teacher-level operational and financial summaries. All amounts are grouped by currency.

## Batches module

Teachers can open `/Tuman/teacher/batches.php` to create and manage course batches. Each batch includes its objective, responsibilities, terms, and a fixed-monthly, instalment, or one-time charge. `/Tuman/teacher/batch-invoice-create.php?id=…` creates one draft invoice per active member; normal invoice issue/cancellation remains unchanged. Students can review memberships at `/Tuman/student/batches.php`, and attendance identifies batch versus individual classes.

## Messages module

Teachers can use `/Tuman/teacher/messages.php` to send an Announcement, Reminder, Warning, Urgent Action, or Official message to one active student or every active member of an active batch. Students can use `/Tuman/student/messages.php` to send an Official message to an active teacher. Messages have a subject, body, and at most one optional PDF, JPG, PNG, DOC, or DOCX attachment (up to 10 MB). Each recipient has an in-app unread notification and protected attachment download; SMTP delivery is attempted only when mail is enabled and configured.
