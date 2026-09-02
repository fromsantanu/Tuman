<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/invoices.php';

$current = tuman_require_role('TEACHER');
$id = filter_var($_GET['id'] ?? $_POST['id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if ($id === false || $id === null) { http_response_code(404); exit('Invoice unavailable.'); }
$invoice = tuman_teacher_invoice(tuman_database(), $current['id'], (int) $id);
if ($invoice === null || $invoice['status'] !== 'DRAFT') { http_response_code(404); exit('Invoice unavailable.'); }
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') { if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; } else { try { tuman_issue_invoice(tuman_database(), $current['id'], (int) $id); header('Location: /Tuman/teacher/invoice-view.php?id=' . $id); exit; } catch (InvalidArgumentException $exception) { http_response_code(404); $error = 'Invoice unavailable.'; } catch (Throwable $exception) { error_log('Tuman invoice issuing failed: ' . $exception->getMessage()); $error = 'Unable to issue the invoice right now.'; } } }
tuman_teacher_page_start('Issue invoice');
?>
<h1>Issue invoice</h1><p>Issue <?= htmlspecialchars($invoice['invoice_number'], ENT_QUOTES, 'UTF-8') ?> for <?= htmlspecialchars(tuman_invoice_money_label($invoice['total_amount']), ENT_QUOTES, 'UTF-8') ?>? Its item snapshot will remain unchanged.</p><?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="id" value="<?= (int) $id ?>"><button type="submit">Issue invoice</button> <a href="/Tuman/teacher/invoice-view.php?id=<?= (int) $id ?>">Keep draft</a></form>
<?php tuman_teacher_page_end(); ?>
