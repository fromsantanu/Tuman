<?php
declare(strict_types=1);
function tuman_student_page_start(string $title): void { ?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?= htmlspecialchars($title,ENT_QUOTES,'UTF-8') ?> — Tuman</title><link rel="stylesheet" href="/Tuman/assets/css/public.css"></head><body><header class="site-header"><div class="container navigation"><a class="brand" href="/Tuman/student/index.php">Tuman<small>Student area</small></a><nav aria-label="Student navigation"><a href="/Tuman/student/index.php">Home</a><a href="/Tuman/student/profile.php">Profile</a><a href="/Tuman/student/attendance.php">Attendance</a><a href="/Tuman/student/invoices.php">Invoices</a><a href="/Tuman/student/payments.php">Payments</a></nav></div></header><main class="section"><div class="container content">
<?php } function tuman_student_page_end(): void { ?></div></main></body></html><?php }
