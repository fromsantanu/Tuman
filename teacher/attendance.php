<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/attendance.php';

$current = tuman_require_role('TEACHER'); $error = null; $records = []; $students = []; $assignmentId = null; $month = null;
try {
    $database = tuman_database(); $students = tuman_teacher_students($database, $current['id']);
    if (isset($_GET['assignment_id']) && $_GET['assignment_id'] !== '') { $assignmentId = tuman_teacher_assignment_id($_GET['assignment_id']); if (tuman_teacher_student($database, $current['id'], $assignmentId) === null) { throw new InvalidArgumentException(); } }
    if (isset($_GET['month']) && $_GET['month'] !== '') { $month = (string) $_GET['month']; if (preg_match('/^\\d{4}-(0[1-9]|1[0-2])$/', $month) !== 1) { throw new InvalidArgumentException(); } }
    $records = tuman_teacher_attendance_list($database, $current['id'], $assignmentId, $month);
} catch (InvalidArgumentException $exception) { http_response_code(404); exit('Attendance unavailable.'); } catch (Throwable $exception) { error_log('Tuman attendance list failed: ' . $exception->getMessage()); $error = 'Attendance cannot be loaded right now.'; }
tuman_teacher_page_start('Attendance');
?>
<h1>Attendance</h1><p>Record and review attendance for your students.</p><form method="get"><p><label>Student <select name="assignment_id"><option value="">All my students</option><?php foreach ($students as $student): ?><option value="<?= (int) $student['assignment_id'] ?>"<?= $assignmentId === (int) $student['assignment_id'] ? ' selected' : '' ?>><?= htmlspecialchars(trim($student['first_name'] . ' ' . ($student['last_name'] ?? '')), ENT_QUOTES, 'UTF-8') ?></option><?php endforeach; ?></select></label> <label>Month <input type="month" name="month" value="<?= htmlspecialchars($month ?? '', ENT_QUOTES, 'UTF-8') ?>"></label> <button type="submit">View</button></p></form><p><a class="button" href="/Tuman/teacher/attendance-create.php">Record attendance</a></p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php else: ?><div style="overflow-x:auto"><table><thead><tr><th>Student</th><th>Date</th><th>Time</th><th>Duration</th><th>Status</th><th>Remarks</th><th>Actions</th></tr></thead><tbody><?php foreach ($records as $record): ?><tr><td><?= htmlspecialchars(trim($record['first_name'] . ' ' . ($record['last_name'] ?? '')), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($record['session_date'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($record['start_time'] ? substr($record['start_time'], 0, 5) . '–' . substr($record['end_time'], 0, 5) : '—', ENT_QUOTES, 'UTF-8') ?></td><td><?= $record['duration_minutes'] === null ? '—' : (int) $record['duration_minutes'] . ' min' ?></td><td><?= htmlspecialchars($record['status'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($record['remarks'] ?? '', ENT_QUOTES, 'UTF-8') ?></td><td><a href="/Tuman/teacher/attendance-edit.php?id=<?= (int) $record['id'] ?>">Edit</a><?php if ($record['status'] !== 'CANCELLED'): ?> · <a href="/Tuman/teacher/attendance-cancel.php?id=<?= (int) $record['id'] ?>">Cancel</a><?php endif; ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; tuman_teacher_page_end(); ?>
