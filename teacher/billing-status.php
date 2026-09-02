<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/billing.php';

$current = tuman_require_role('TEACHER');
$id = filter_var($_GET['id'] ?? $_POST['id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if ($id === false || $id === null) { http_response_code(404); exit('Billing unavailable.'); }
$record = tuman_teacher_billing_rule(tuman_database(), $current['id'], (int) $id);
if ($record === null || $record['status'] !== 'ACTIVE') { http_response_code(404); exit('Billing unavailable.'); }
$error = null; $effectiveTo = $record['effective_to'] ?? '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') { $effectiveTo = trim((string) ($_POST['effective_to'] ?? '')); if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; } else { try { tuman_deactivate_billing_rule(tuman_database(), $current['id'], (int) $id, $effectiveTo); header('Location: /Tuman/teacher/billing.php?deactivated=1'); exit; } catch (InvalidArgumentException $exception) { $error = $exception->getMessage(); } catch (Throwable $exception) { error_log('Tuman billing deactivation failed: ' . $exception->getMessage()); $error = 'Unable to end the billing rule right now.'; } } }
tuman_teacher_page_start('End billing rule');
?>
<h1>End billing rule</h1><p>End <?= htmlspecialchars(tuman_billing_rate_label($record['rate'], $record['billing_mode']), ENT_QUOTES, 'UTF-8') ?>? The rule will be retained as inactive history.</p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="id" value="<?= (int) $id ?>"><p><label>Effective to (optional) <input type="date" name="effective_to" value="<?= htmlspecialchars($effectiveTo, ENT_QUOTES, 'UTF-8') ?>"></label></p><p><button type="submit">End billing rule</button> <a href="/Tuman/teacher/billing.php">Keep rule</a></p></form>
<?php tuman_teacher_page_end(); ?>
