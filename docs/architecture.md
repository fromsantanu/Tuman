# Tuman architecture

## Purpose and scope

Tuman is a Tuition Management System for three roles: Administrator, Teacher, and Student. The application will be built incrementally in PHP without a large framework so that its structure remains approachable to students.

This document records the initial architectural decisions for Phase 00. It describes the intended design; it does not mean that the described modules already exist.

## Proposed project structure

```text
Tuman/
├── public/                 # Public entry pages and static web root
│   ├── index.php
│   ├── about.php
│   ├── login.php
│   └── logout.php
├── admin/                  # Administrator-only pages
├── teacher/                # Teacher-only pages
├── student/                # Student-only pages
├── config/                 # Environment loading and database configuration
├── includes/               # Small reusable helpers, guards, and layout parts
├── services/               # Reusable domain services (invoice, payment, email, PDF)
├── templates/              # Shared HTML layout and email/PDF templates
├── database/               # Versioned schema, migrations, and development seeds
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
├── docs/
├── tests/
├── .env.example
├── .gitignore
├── README.md
└── CHANGELOG.md
```

The directories above will be created in Phase 01 as needed. Keeping public pages separate from role-specific pages makes access boundaries visible, but every protected request must still be checked on the server.

## Public website (Phase 04)

The public site uses `public/index.php` and `public/about.php`. `templates/public_header.php` and `templates/public_footer.php` provide the shared branded header, Home/About/Login navigation, and footer. `assets/css/public.css` provides responsive layout and visual styling without an external framework or JavaScript dependency.

Public navigation exposes only public pages and the existing login route; it never links to role-protected placeholders. Page URLs retain the existing `/Tuman/` installation path established by the Phase 03 authentication routes.

## Application layers

## International students and currencies (Phase 10A)

`config/currencies.php` centrally allow-lists supported ISO 3166-1 country and ISO 4217 currency codes. Billing rules use one currency, invoices snapshot it, and mixed-currency source items are rejected. Tuman performs no exchange-rate conversion.

1. **Pages/controllers** receive a request, require authentication and role access, validate input, and select a template.
2. **Services** contain reusable business rules that should not be copied between pages, such as invoice-total calculation and payment validation.
3. **Database access** uses PDO and parameterized SQL. Queries that access owned records must include ownership constraints.
4. **Templates** render escaped output. They never decide authorization or execute business logic.
5. **Configuration** reads environment-specific settings and is excluded from version control.

This is intentionally a small modular architecture, not a full MVC framework.

## Authentication and authorization

All users authenticate through one `tmn_users` table with a username and a PHP password hash. After a successful login, Tuman regenerates the session identifier and stores only the authenticated user's identity and role needed for access checks.

Every protected page will use a reusable authentication guard. A role guard will allow only the appropriate role. Ownership guards are additionally required for Teacher and Student data:

- Administrators may access system-wide user data within their administrative permissions.
- Teachers may access only students linked to their own teacher profile, and data belonging to those students.
- Students may access only records connected to their own student profile.

Navigation visibility is only a convenience; database queries and server-side guards enforce the actual permission boundary.

### Implemented Phase 03 flow

`public/login.php` validates its CSRF token and credentials, then uses a parameterized lookup against `tmn_users` and `password_verify()`. Only an `ACTIVE` user with one of the database roles (`ADMIN`, `TEACHER`, or `STUDENT`) can authenticate. On success, `last_login_at` is updated in UTC, the session ID is regenerated, and only the user ID and role are stored in the session. The user is then sent to the matching protected placeholder area.

`includes/auth.php` centralizes login, logout, current-user, role-home, and role-guard behaviour. `tuman_require_role()` redirects unauthenticated requests to the login page and returns HTTP 403 for an authenticated user with the wrong role. Later ownership checks will extend this layer rather than trusting request parameters.

`includes/csrf.php` creates one random token per session and uses `hash_equals()` for validation. State-changing forms must include `tuman_csrf_token()` and validate it with `tuman_require_csrf()` (or `tuman_csrf_is_valid()` when a page must re-render an error). Login and logout already follow this rule.

`includes/session.php` uses a named, strict session with HttpOnly and SameSite=Lax cookies. The Secure flag is enabled only when the request uses HTTPS, keeping local HTTP development usable. Logout clears session data, expires the browser cookie, and destroys the server-side session.

## Administrator module (Phase 05)

All `/admin/` pages call `tuman_require_role('ADMIN')` before loading any data. `services/admin_users.php` centralizes account validation, creation, editing, status changes, password resets, and the final-active-Administrator safeguard. It uses PDO prepared statements and transactions for role/status changes that could otherwise lock every Administrator out of the system.

Accounts are never physically deleted in this module: a status change uses `ACTIVE` or `INACTIVE`. An Administrator cannot deactivate their own account or remove their own Administrator role. The final active Administrator cannot be deactivated or demoted. Password reset accepts a new password and confirmation, hashes the password with PHP's password API, and never renders or logs either the password or its hash.

`services/activity_log.php` writes safe `tmn_activity_log` records for user creation, update, role/status changes, and password reset. Logged details never include passwords or password hashes. Phase 05 deliberately does not create Teacher or Student profile rows; profiles will be created through their own later workflows.

## Teacher module (Phase 06)

Every Teacher page requires the `TEACHER` role. `services/teacher_students.php` is the single place that queries Teacher-owned students: every lookup combines the requested assignment ID with the authenticated `teacher_user_id`. A request for another Teacher's assignment therefore returns the same safe not-found result as an invalid ID.

Student enrolment creates a `STUDENT` account, student profile, active teacher-student assignment, and safe activity-log entry in one transaction. A profile update is also transactional. Deactivation changes only the assignment to `INACTIVE` and records its end date; it does not delete the account, profile, or historical relationship. Teachers may edit permitted profile/contact fields but not usernames, roles, passwords, account status, or financial data.

## Responsibilities module (Phase 07)

The Responsibilities module uses existing `tmn_responsibilities` records linked to `tmn_teacher_students`. A Teacher can create a responsibility only for an active assignment that belongs to that Teacher. Every list, lookup, update, and deactivation query joins through `tmn_teacher_students.teacher_user_id`, so a responsibility belonging to another Teacher is treated as unavailable.

Each record identifies whether the responsibility is for the `TEACHER` or `STUDENT`, has a title, optional details, effective-from date, optional effective-to date, and `ACTIVE` or `INACTIVE` status. Dates are server-validated, including the rule that an end date cannot precede its start date. Deactivation retains the row for history, and concise activity-log entries record create, update, and status changes without storing the details text.

## Attendance module (Phase 08)

The Attendance module uses `tmn_attendance` records linked to `tmn_teacher_students`. All queries join through `teacher_user_id`, so a Teacher can access only attendance belonging to their own assignments. New records require an active assignment, and session dates must fall within the assignment dates.

`PRESENT` records require valid start and end times and calculate `duration_minutes` server-side. `ABSENT`, `LEAVE`, `HOLIDAY`, and `CANCELLED` records consistently store null time and duration values. The existing assignment/date/start-time key supports multiple sessions per day when their start times differ. Cancelling changes the record to `CANCELLED`, clears timing data, and retains history. Concise activity events record creation, update, and status change without copying remarks.

## Billing Rules module (Phase 09)

The Billing Rules module uses `tmn_student_billing`, linked to `tmn_teacher_students`. Every listing and operation joins through `teacher_user_id`, preventing a Teacher from reading or changing another Teacher's rate rules. New rules require an active assignment, and all rule dates must remain within the assignment dates.

Rules support `HOURLY` and `FIXED_MONTHLY` modes with validated non-negative two-decimal rates. For an assignment and mode, active effective-date ranges cannot overlap; the service locks active rules and performs the check and write in one transaction. Ending a rule changes it to `INACTIVE`, optionally records an end date, and preserves rate history. Existing invoice tables are not changed, and future invoices will retain their own rate snapshot. Activity entries record safe create, update, and status-change metadata only.

## Invoices module (Phase 10)

The Invoices module uses `tmn_invoices`, `tmn_invoice_items`, and the `GLOBAL` row of `tmn_invoice_sequences`. Every invoice query joins through `tmn_teacher_students.teacher_user_id`, so a Teacher can access only their own invoices. Creation is limited to an active assignment and one full calendar month; a duplicate non-cancelled invoice for the same assignment/month is blocked within the creation transaction.

Invoice items are created as immutable snapshots. Present hourly attendance creates session items using the hourly billing rule effective on its date; fixed-monthly rules effective on the first day create one monthly item. Historical inactive billing rules remain eligible when their effective dates cover the billed work. Quantities and money are calculated with integer minor units and half-up rounding, not PHP floats. The transaction locks and increments the global sequence, inserts the draft header/items, and writes its audit event together. A draft can become `ISSUED` or `CANCELLED`; issued items are not recalculated and invoice rows/items are never deleted.

## Security baseline

- PDO prepared statements for all values originating outside trusted program code.
- `password_hash()` and `password_verify()` for passwords; passwords are never stored or logged in plain text.
- CSRF tokens on all state-changing forms.
- Output escaping in templates to reduce XSS risk.
- Server-side validation for all input and identifiers.
- Session ID regeneration after login and complete session destruction at logout.
- Friendly production error messages; technical details go to logs, not the browser.
- Secrets live in an uncommitted `.env` file, with keys documented in `.env.example`.
- Login throttling is intentionally deferred to the security-audit phase; no account or request data is yet collected for rate limiting.

## Domain services planned for later phases

The following services will be introduced only when their related phase begins:

- User and profile management
- Student enrolment/assignment
- Responsibilities management
- Attendance recording and duration calculation
- Billing-rate selection by effective date
- Invoice numbering, generation, and totals
- Payment validation and invoice-balance calculation
- Email delivery and delivery logging
- PDF invoice rendering

## Key architectural decisions before coding

1. **One teacher per student initially.** The `tmn_teacher_students` assignment table is used even though it has one active teacher per student in the first release. This retains an assignment history and leaves room for future multi-teacher support.
2. **Table naming is fixed.** Every current and future database table must begin with `tmn_`.
3. **Multiple sessions per day are allowed by design.** Attendance has its own session identifier and unique session start; the application can initially offer a simple one-session-per-date workflow while the schema does not block later expansion.
4. **Money is stored as `DECIMAL`, never float.** Calculations use deterministic two-decimal rounding rules.
5. **Financial history is immutable in effect.** Invoice items keep a snapshot of description, quantity, and rate. Rate changes therefore cannot rewrite an issued invoice.
6. **Removal is normally status-based.** Users and assignments are deactivated/ended rather than deleted where history depends on them. Financial records are retained and corrected through statuses or reversal-style records rather than casual deletion.
7. **Invoice numbers use a database-backed sequence.** A transaction will reserve a unique number; PHP must not generate invoice numbers by counting rows.

## Decisions deferred until their phases

- Exact invoice-number display format and financial-year reset policy.
- Whether teachers can edit only contact information or a larger set of student profile fields.
- Default due-date policy and discount rules.
- Initial administrator provisioning method for deployment.
- Choice of email and PDF libraries/provider, if those phases require one.
- Whether cancelled attendance sessions count as zero hours in all reports (the recommended initial rule is yes).
