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
if ($record === null || $record['status'] !== 'ACTIVE') { http_response_code(404); exit('Responsibility unavailable.'); }
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; }
    else { try { tuman_deactivate_responsibility(tuman_database(), $current['id'], (int) $id); header('Location: /Tuman/teacher/responsibilities.php?deactivated=1'); exit; } catch (InvalidArgumentException $exception) { http_response_code(404); $error = 'Responsibility unavailable.'; } catch (Throwable $exception) { error_log('Tuman responsibility deactivation failed: ' . $exception->getMessage()); $error = 'Unable to deactivate the responsibility right now.'; } }
}
tuman_teacher_page_start('Deactivate responsibility');
?>
<h1>Deactivate responsibility</h1><p>Deactivate “<?= htmlspecialchars($record['title'], ENT_QUOTES, 'UTF-8') ?>”? Its history will be retained.</p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="id" value="<?= (int) $id ?>"><button type="submit">Deactivate responsibility</button> <a href="/Tuman/teacher/responsibilities.php">Cancel</a></form>
<?php tuman_teacher_page_end(); ?>
