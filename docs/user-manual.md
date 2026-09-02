# Tuman user manual

## Invoice PDFs and email notices (Phases 13-14)

Teachers can save separate Indian and international payment instructions in **Payment details**. Invoice detail pages provide a PDF download including the student name/address and currency-appropriate payment block. **Email invoice** and **Send reminder** create pending queue entries; they are not sent until SMTP is configured. Receipt email is pending.

## Status

Tuman is in architecture planning. There are no usable application screens yet, so this is an outline for the manual that will be completed as modules are implemented.

## Planned audiences

- **Administrators:** manage accounts and system-level settings.
- **Teachers:** manage assigned students, responsibilities, attendance, billing, invoices, and payments.
- **Students:** view and update permitted profile details; view only their own attendance and financial information.

## Planned manual sections

1. Signing in and signing out
2. Administrator account management
3. Teacher student management
4. Responsibilities and attendance
5. Billing, invoices, and payments
6. Student self-service views
7. Error messages and support

Each implemented section will explain its purpose, required permissions, normal steps, validation messages, and any irreversible or historical-record behaviour.

## Signing in and out (Phase 03)

Open `/public/login.php`, enter the username and password supplied by an administrator, then select **Sign in**. Active Administrator, Teacher, and Student accounts are sent to their own protected landing pages. Those pages are temporary access-control checks, not the completed dashboards.

If the details are wrong or the account is inactive, Tuman displays the same general sign-in failure message. Use the **Sign out** button on a protected page to end the session. The sign-out action uses a protected form and cannot be performed by opening the logout URL directly.

## Public pages (Phase 04)

Open the Home page at `/public/index.php` to see Tuman’s purpose and planned benefits. Select **About** to learn about the intended users, roles, planned features, and secure technology approach. Select **Login** when you have an account.

The Home and About pages are available to everyone. Administrator, Teacher, and Student areas remain protected and are not listed in the public navigation.

## Administrator user management (Phase 05)

After signing in as an Administrator, open the Administrator area and select **Users**. You can create accounts, edit usernames/email addresses/roles, change an account’s active status, and reset a password. New passwords require confirmation and at least 12 characters.

Deactivating an account prevents that user from signing in but retains its history. Tuman prevents you from deactivating your own account, removing your own Administrator role, or leaving the system with no active Administrator.

## Teacher student management (Phase 06)

After signing in as a Teacher, use **My students** to view students assigned to you and **Enrol student** to create a new Student account and assignment. Teachers can view and update permitted student contact and guardian details, but cannot edit roles, usernames, passwords, account status, or financial information.

To end an active teaching relationship, choose **Deactivate** from that student’s entry and confirm the action. The Student account and assignment history are kept; only the Teacher-student relationship becomes inactive.

## Responsibilities (Phase 07)

After signing in as a Teacher, select **Responsibilities** from the Teacher area. Choose **Add responsibility**, select one of your active students, choose whether the responsibility is for the Teacher or Student, provide a title, and set the effective date. Details and an effective end date are optional.

Use **Edit** to correct a responsibility. To end a responsibility, select **Deactivate** and confirm the action. Deactivation does not delete it: Tuman keeps the inactive record as history. Teachers can see and manage only responsibilities linked to their own student assignments.

## Attendance (Phase 08)

After signing in as a Teacher, select **Attendance**. You can view all of your attendance records or filter by one of your students and a month. Choose **Record attendance** to add an entry for an active student assignment.

For a `PRESENT` session, enter the session date, start time, and end time; Tuman calculates the duration automatically. For `ABSENT`, `LEAVE`, or `HOLIDAY`, do not enter times. You can add an optional remark to any record.

Use **Edit** to correct an attendance entry. To preserve an entry but mark that a planned class did not take place, select **Cancel** and confirm. The record remains visible as `CANCELLED`, while its times and duration are removed. Multiple sessions can be recorded on the same day when they have different start times.

## Billing Rules (Phase 09)

After signing in as a Teacher, select **Billing**. You can view all of your billing rules or filter them by one of your students. Choose **Add billing rule**, select an active student, then choose either **Hourly** or **Fixed monthly**, enter the rate, and set when it takes effect.

Tuman prevents two active rules with the same billing mode from covering the same dates for one student. To stop a rate, select **End** and optionally enter its final effective date. The rule remains as inactive history. Editing or ending a billing rule does not change existing invoices or payments.

## Invoices (Phase 10)

After signing in as a Teacher, select **Invoices**. Choose **Generate draft invoice**, select an active student, choose the billing month, and enter the invoice date. A due date is optional. Tuman generates the full calendar-month invoice from qualifying attendance and billing rules; you do not enter totals or items manually.

Open an invoice to review its item descriptions, quantities, rates, and totals. These values are snapshots and remain unchanged if attendance or billing records are later corrected. Choose **Issue invoice** to change a reviewed draft to issued, or **Cancel draft** to retain it as cancelled history. Payments are not recorded in this module yet.
