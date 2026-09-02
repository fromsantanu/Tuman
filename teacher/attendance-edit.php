<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/attendance.php';

$current = tuman_require_role('TEACHER');
$id = filter_var($_GET['id'] ?? $_POST['id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if ($id === false || $id === null) { http_response_code(404); exit('Attendance unavailable.'); }
$record = tuman_teacher_attendance(tuman_database(), $current['id'], (int) $id);
if ($record === null) { http_response_code(404); exit('Attendance unavailable.'); }
$error = null;
$values = ['session_date' => $record['session_date'], 'status' => $record['status'], 'start_time' => $record['start_time'] === null ? '' : substr($record['start_time'], 0, 5), 'end_time' => $record['end_time'] === null ? '' : substr($record['end_time'], 0, 5), 'remarks' => $record['remarks'] ?? ''];
if ($_SERVER['REQUEST_METHOD'] === 'POST') { foreach ($values as $key => $value) { $values[$key] = trim((string) ($_POST[$key] ?? '')); } if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; } else { try { tuman_update_attendance(tuman_database(), $current['id'], (int) $id, $values); header('Location: /Tuman/teacher/attendance.php?updated=1'); exit; } catch (InvalidArgumentException $exception) { $error = $exception->getMessage(); } catch (Throwable $exception) { error_log('Tuman attendance update failed: ' . $exception->getMessage()); $error = 'Unable to update attendance right now.'; } } }
tuman_teacher_page_start('Edit attendance');
?>
<h1>Edit attendance</h1><p>For a present session, provide both start and end times. Duration is recalculated automatically.</p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="id" value="<?= (int) $id ?>"><p><label>Session date <input type="date" name="session_date" required value="<?= htmlspecialchars($values['session_date'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Status <select name="status"><?php foreach (TUMAN_ATTENDANCE_STATUSES as $status): ?><option value="<?= $status ?>"<?= $status === $values['status'] ? ' selected' : '' ?>><?= $status ?></option><?php endforeach; ?></select></label></p><p><label>Start time <input type="time" name="start_time" value="<?= htmlspecialchars($values['start_time'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>End time <input type="time" name="end_time" value="<?= htmlspecialchars($values['end_time'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Remarks <textarea name="remarks" maxlength="500" rows="4"><?= htmlspecialchars($values['remarks'], ENT_QUOTES, 'UTF-8') ?></textarea></label></p><p><button type="submit">Save changes</button> <a href="/Tuman/teacher/attendance.php">Cancel</a></p></form>
<?php tuman_teacher_page_end(); ?>
