# Tuman — Tuition Management System

Tuman is a planned PHP and MySQL application for individual tuition teachers and small tuition organisations. It will help administrators, teachers, and students manage enrolment, attendance, billing, invoices, and payments.

## Current status

**Phase 14 — Email Notifications** is partially complete. Teachers can queue invoice notices and payment reminders for their own students; actual SMTP delivery and payment-receipt emails remain pending configuration and implementation.

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

Complete Phase 14 SMTP delivery and payment-receipt emails.
