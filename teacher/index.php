<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
tuman_require_role('TEACHER');
 tuman_teacher_page_start('Teacher dashboard'); ?>
<h1>Teacher dashboard</h1><p>Manage students, responsibilities, attendance, billing rules, and monthly invoices for your assigned learners. Payments will be added in a later phase.</p><p><a class="button" href="/Tuman/teacher/students.php">My students</a> <a class="button" href="/Tuman/teacher/responsibilities.php">Responsibilities</a> <a class="button" href="/Tuman/teacher/attendance.php">Attendance</a> <a class="button" href="/Tuman/teacher/billing.php">Billing</a> <a class="button" href="/Tuman/teacher/invoices.php">Invoices</a> <a class="button" href="/Tuman/teacher/student-create.php">Enrol student</a></p>
<form method="post" action="/Tuman/public/logout.php"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><button type="submit">Sign out</button></form>
<?php tuman_teacher_page_end(); ?>
