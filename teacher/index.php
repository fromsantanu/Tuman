<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php'; require_once dirname(__DIR__).'/services/profiles.php';
$current=tuman_require_role('TEACHER');$profile=tuman_profile(tuman_database(),$current['id'],'TEACHER');$name=trim(($profile['first_name']??'').' '.($profile['last_name']??'')) ?: ($profile['username']??'Teacher');
 tuman_teacher_page_start('Teacher dashboard'); ?>
<h1>Welcome, <?= htmlspecialchars($name,ENT_QUOTES,'UTF-8') ?></h1><p>Manage students, responsibilities, attendance, billing rules, invoices, payments, and credits for your assigned learners.</p><p><a class="button" href="/Tuman/teacher/students.php">My students</a> <a class="button" href="/Tuman/teacher/responsibilities.php">Responsibilities</a> <a class="button" href="/Tuman/teacher/attendance.php">Attendance</a> <a class="button" href="/Tuman/teacher/billing.php">Billing</a> <a class="button" href="/Tuman/teacher/invoices.php">Invoices</a> <a class="button" href="/Tuman/teacher/student-create.php">Enrol student</a></p>
<form method="post" action="/Tuman/public/logout.php"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><button type="submit">Sign out</button></form>
<?php tuman_teacher_page_end(); ?>
