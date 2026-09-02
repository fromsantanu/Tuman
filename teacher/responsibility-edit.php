<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/responsibilities.php';

$current = tuman_require_role('TEACHER');
$id = filter_var($_GET['id'] ?? $_POST['id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if ($id === false || $id === null) { http_response_code(404); exit('Responsibility unavailable.'); }
$record = tuman_teacher_responsibility(tuman_database(), $current['id'], (int) $id);
if ($record === null) { http_response_code(404); exit('Responsibility unavailable.'); }
$error = null;
$values = ['responsibility_for' => $record['responsibility_for'], 'title' => $record['title'], 'details' => $record['details'] ?? '', 'effective_from' => $record['effective_from'], 'effective_to' => $record['effective_to'] ?? ''];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    foreach ($values as $key => $value) { $values[$key] = trim((string) ($_POST[$key] ?? '')); }
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; }
    else { try { tuman_update_responsibility(tuman_database(), $current['id'], (int) $id, $values); header('Location: /Tuman/teacher/responsibilities.php?updated=1'); exit; } catch (InvalidArgumentException $exception) { $error = $exception->getMessage(); } catch (Throwable $exception) { error_log('Tuman responsibility update failed: ' . $exception->getMessage()); $error = 'Unable to update the responsibility right now.'; } }
}
tuman_teacher_page_start('Edit responsibility');
?>
<h1>Edit responsibility</h1><p>Update the responsibility while keeping its history with this student.</p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="id" value="<?= (int) $id ?>"><p><label>Responsibility for <select name="responsibility_for"><?php foreach (TUMAN_RESPONSIBILITY_FOR as $for): ?><option value="<?= $for ?>"<?= $for === $values['responsibility_for'] ? ' selected' : '' ?>><?= $for ?></option><?php endforeach; ?></select></label></p><p><label>Title <input name="title" maxlength="200" required value="<?= htmlspecialchars($values['title'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Details <textarea name="details" rows="4"><?= htmlspecialchars($values['details'], ENT_QUOTES, 'UTF-8') ?></textarea></label></p><p><label>Effective from <input type="date" name="effective_from" required value="<?= htmlspecialchars($values['effective_from'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Effective to <input type="date" name="effective_to" value="<?= htmlspecialchars($values['effective_to'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><button type="submit">Save changes</button> <a href="/Tuman/teacher/responsibilities.php">Cancel</a></p></form>
<?php tuman_teacher_page_end(); ?>
