# Testing approach

## Phases 13-14 results

| Test | Result | Notes |
| --- | --- | --- |
| Payment-details migration and PDF export lookup | PASS | Local database table exists and an owned invoice resolves for export. |
| Notification page/service syntax | PASS | Changed PHP files passed `php -l`. |
| SMTP delivery and receipt emails | BLOCKED | Delivery is intentionally not configured and receipt email is pending. |

## Current phase

Phase 02 added PHP configuration and SQL source files. PHP syntax was checked successfully for the environment loader, PDO helper, and connection test. The schema contains 14 tables and the naming check confirmed they all use `tmn_`.

The PDO test correctly returns a safe configuration error when `.env` is absent. On this machine, the running MySQL server rejects the default XAMPP `root`/blank-password credentials, so applying and integration-testing the SQL requires valid local MySQL credentials. No credentials were guessed or added to source control.

## Phase 03 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for authentication files and protected placeholders | PASS | `php -l` completed without errors. |
| CSRF valid and invalid token validation | PASS | Covered by `tests/auth_helpers.php`. |
| Session ID regeneration after login | PASS | Covered by `tests/auth_helpers.php`. |
| Session identity setup and logout clearing | PASS | Covered by `tests/auth_helpers.php`. |
| Login with valid seeded account | PASS | Verified against the configured separate MySQL database. |
| Wrong/unknown/inactive account rejection | PASS | Inactive check used a transaction and was rolled back. |
| Last-login update | PASS | Verified after successful Administrator authentication. |
| Direct Admin URL without authentication | PASS | Redirects to the login page. |
| SQL injection login input | NOT APPLICABLE | Query is parameterized; no unsafe dynamic SQL exists. |

The CLI helper test sets its session location to the system temporary folder because this workspace cannot write to XAMPP's web-server session folder. This is a test-environment adjustment only; it does not alter application session settings.

## Phase 04 results

| Test | Result | Notes |
| --- | --- | --- |
| Home page renders | PASS | Verified in a local browser. |
| About page renders | PASS | Verified in a local browser. |
| Home, About, and Login navigation | PASS | Shared navigation links point to the expected public routes. |
| Protected placeholders absent from public navigation | PASS | No Admin, Teacher, or Student protected links are present. |
| Narrow-screen layout | PASS | At 390px width, navigation and cards stack with no horizontal overflow. |
| PHP syntax validation | PASS | Public pages and templates were checked with `php -l`. |
| Live authentication after public-layout change | BLOCKED | Valid local database credentials are still required. |

## Phase 05 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for Administrator pages and services | PASS | All PHP files pass `php -l`. |
| Administrator input validation | PASS | Valid and invalid username/email/role combinations checked at service level. |
| CSRF/session helper checks | PASS | Existing helper test passes. |
| Server-side Administrator guard | PASS | Every Administrator page calls `tuman_require_role('ADMIN')`. |
| Create user and password reset | PASS | Verified inside a rolled-back transaction. |
| Status change and activity log | PASS | Verified with a seeded student restored to `ACTIVE`. |
| Final active Administrator protections | PASS | Self-demotion, self-deactivation, final-admin demotion, and final-admin deactivation were rejected. |
| Inactive-user login rejection after status change | PASS | Verified after a real status change, then restored. |

## Phase 06 results

| Test | Result | Notes |
| --- | --- | --- |
| Teacher ownership scope | PASS | Teacher A can retrieve her student but not Teacher B's assignment. |
| Student enrolment transaction | PASS | User, profile, assignment, and audit entry were created in a transaction, then rolled back. |
| Student profile update | PASS | Verified during the enrolment transaction. |
| Assignment deactivation | PASS | Verified during the enrolment transaction and rolled back. |
| Invalid email | PASS | Rejected by server-side validation. |
| Transaction rollback | PASS | No temporary user remained after test rollback. |
| Teacher role guards | PASS | All Teacher pages enforce `tuman_require_role('TEACHER')`. |
| Unauthenticated Teacher URL | PASS | Redirects to the public login page. |

## Testing strategy for later phases

## Phase 10 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for Invoices service and pages | PASS | All invoice PHP files pass `php -l`. |
| Hourly invoice generation | PASS | A 90-minute session produced a 1.50-hour, ₹450.00 snapshot item at ₹300.00/hour. |
| Fixed-monthly and historical-rate generation | PASS | Fixed-monthly and inactive historical hourly rules produced the expected ₹2,200.00 total. |
| Item snapshot immutability | PASS | A source attendance update did not change the already-generated invoice item. |
| Dates, no-items, and duplicate validation | PASS | Invalid month, no billable work, due date before invoice date, and duplicate active invoice were rejected. |
| Invoice sequence | PASS | `GLOBAL` sequence reserved `TMN-2026-000003` transactionally. |
| Teacher ownership | PASS | Teacher B could not retrieve Teacher A's invoice; Teacher A could not create an invoice for Teacher B's assignment. |
| Draft state transitions | PASS | Draft issue and cancellation worked; cancelling issued invoice was rejected; a cancelled month allowed a replacement draft. |
| Audit events and rollback | PASS | Creation/issue events were verified and every test invoice, item, sequence increment, and audit entry rolled back. |
| CSRF and Teacher guards | PASS | Source verification confirms all state changes validate CSRF and every Invoice page requires the Teacher role. |
| Browser role-route checks | BLOCKED | The sandboxed PHP server cannot write to XAMPP's session directory. Unauthenticated access redirects to login; authenticated browser-session checks require the normal local web-server environment. |

## Phase 09 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for Billing pages and service | PASS | All Billing PHP files pass `php -l`. |
| Billing modes and decimal normalization | PASS | Live test created fixed-monthly and hourly rules; `1000.5` stored as `1000.50`. |
| Validation and assignment-date bounds | PASS | Invalid mode, negative/over-precision rate, invalid dates, inverted range, and out-of-assignment dates were rejected. |
| Active same-mode overlap | PASS | A conflicting active range was rejected inside the transactional service. |
| Non-overlapping and different-mode rules | PASS | A following fixed-monthly range and overlapping hourly rule were accepted where applicable. |
| Teacher ownership | PASS | Teacher B could not read or end Teacher A's rule; Teacher A could not create a rule for Teacher B's assignment. |
| Update and inactive history | PASS | Rate update succeeded; ending the rule retained its row as `INACTIVE` with its end date. |
| Audit events and rollback | PASS | Safe create/update/status events were verified and all test records/logs rolled back. |
| CSRF and Teacher guards | PASS | Source verification confirms state changes validate CSRF and every Billing page requires the Teacher role. |
| Browser role-route checks | BLOCKED | The sandboxed PHP server cannot write to XAMPP's session directory. Unauthenticated access redirects to login; authenticated browser-session checks require the normal local web-server environment. |

## Phase 08 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for Attendance pages and service | PASS | All new PHP files pass `php -l`. |
| Present session duration | PASS | A 12:34–14:04 session stored 90 calculated minutes. |
| Non-present timing data | PASS | An `ABSENT` record cleared browser-supplied times and duration. |
| Input and assignment-date validation | PASS | Missing date, invalid status, missing/invalid present times, and an out-of-assignment date were rejected. |
| Duplicate session prevention | PASS | Duplicate assignment/date/start-time was rejected before insert. |
| Teacher ownership | PASS | Teacher B could not access Teacher A's record; Teacher A could not create an entry for Teacher B's assignment. |
| Update and cancellation history | PASS | Update recalculated duration; cancellation set `CANCELLED`, cleared time/duration, and retained the row. |
| Transaction rollback | PASS | All live verification records and activity entries were rolled back. |
| CSRF and Teacher guards | PASS | Source verification confirms all state changes validate CSRF and all Attendance pages require the Teacher role. |
| Browser role-route checks | BLOCKED | The sandboxed PHP server cannot write to XAMPP's session directory. Unauthenticated access redirects to login; authenticated browser-session checks require the normal local web-server environment. |

## Phase 07 results

| Test | Result | Notes |
| --- | --- | --- |
| PHP syntax for Responsibilities pages and service | PASS | All Teacher PHP files pass `php -l`. |
| Create responsibility | PASS | Live database test created an active record for Teacher A's active assignment. |
| Ownership boundary | PASS | Teacher B could not retrieve Teacher A's responsibility, and Teacher A could not create one for Teacher B's assignment. |
| Edit and deactivate | PASS | Both actions were verified in the live database test. |
| Validation | PASS | Invalid type, missing title, invalid date, and inverted date range were rejected. |
| Audit record | PASS | The creation audit entry referenced the new responsibility ID. |
| Transaction rollback | PASS | The verification data and its activity entries were rolled back. |
| CSRF and Teacher guards | PASS | Source verification confirms all responsibility state changes validate CSRF and all pages require the Teacher role. |
| Browser role-route checks | BLOCKED | The sandboxed local PHP server cannot write to XAMPP's session directory, so it cannot retain an authenticated browser session. Unauthenticated access did redirect to login. |

Each phase will record the commands and checks actually performed. Testing will cover the following categories when relevant:

- **Normal flows:** valid inputs and successful expected outcomes.
- **Validation failures:** missing, malformed, or out-of-range values.
- **Authentication:** valid login, incorrect password, inactive user, logout, and protected URL access.
- **Authorization:** administrator/teacher/student boundaries, including attempts to manipulate identifiers.
- **Security:** CSRF rejection, output escaping, session handling, and parameterized database queries.
- **Financial integrity:** rate history, invoice totals, payment totals, rejected overpayment, and void/cancellation behavior.
- **Regression:** existing functionality remains usable after a later phase is added.

## Initial high-risk acceptance cases

| Area | Expected result |
| --- | --- |
| Inactive account login | Rejected without revealing sensitive details. |
| Teacher A requests Teacher B's student | Rejected by an ownership-scoped server-side query. |
| Student changes an attendance or invoice identifier | No data belonging to another student is returned. |
| Billing-rate update | Existing invoice item rates do not change. |
| Payment exceeding outstanding balance | Rejected unless an explicit future overpayment policy enables it. |
| Invalid state-changing request without CSRF token | Rejected. |
