<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/services/backup_diagnostic.php';

tuman_require_role('ADMIN');
$results = [];
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) {
        $error = 'Your request could not be verified. Please try again.';
    } else {
        try {
            $results = tuman_backup_diagnostic_run();
        } catch (Throwable $exception) {
            error_log('Tuman backup diagnostic failed: ' . $exception->getMessage());
            $error = $exception->getMessage();
        }
    }
}
tuman_admin_page_start('Backup diagnostic');
?>
<h1>Backup diagnostic</h1>
<p>This protected test checks the backup configuration, database connection, mysqldump execution, and dump verification. It creates no retained backup and deletes its temporary files.</p>
<?php if ($error): ?><p role="alert">Diagnostic failed: <?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
<?php if ($results !== []): ?><p role="status">Diagnostic passed:</p><ul><?php foreach ($results as $result): ?><li><?= htmlspecialchars($result, ENT_QUOTES, 'UTF-8') ?></li><?php endforeach; ?></ul><?php endif; ?>
<form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><p><button type="submit">Run backup diagnostic</button> <a class="button" href="/Tuman/admin/maintenance.php">Back to maintenance</a></p></form>
<?php tuman_admin_page_end();
