<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/maintenance.php';

$current = tuman_require_role('ADMIN');
$database = tuman_database();
$error = null; $notice = null; $preview = null; $cutoff = (string) ($_POST['cutoff_date'] ?? '');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; }
    else {
        try {
            $action = (string) ($_POST['action'] ?? '');
            if ($action === 'backup') {
                $backup = tuman_maintenance_run_backup($database, $current['id']);
                $notice = 'Database backup completed successfully (' . $backup['identifier'] . ').';
            } elseif ($action === 'preview') {
                $result = tuman_maintenance_record_preview($database, $current['id'], $cutoff);
                $preview = $result['counts']; $notice = 'This is a preview only. No data was deleted.';
            } elseif ($action === 'purge') {
                if (!hash_equals('PURGE', trim((string) ($_POST['confirmation'] ?? '')))) { throw new InvalidArgumentException('Enter PURGE exactly to confirm this deletion.'); }
                $result = tuman_maintenance_execute_purge($database, $current['id'], $cutoff);
                $notice = 'Eligible operational records were purged after a new successful backup.';
                $preview = $result['counts'];
            } else { throw new InvalidArgumentException('Choose a valid maintenance action.'); }
        } catch (InvalidArgumentException $exception) { $error = $exception->getMessage(); }
        catch (Throwable $exception) { error_log('Tuman maintenance request failed: ' . $exception->getMessage()); $error = 'The maintenance request could not be completed. Check the configuration and try again.'; }
    }
}
$maintenanceReady = true; $backups = []; $purges = [];
try { $backups = tuman_maintenance_recent_backups($database); $purges = tuman_maintenance_recent_purges($database); }
catch (Throwable $exception) { error_log('Tuman maintenance setup check failed: ' . $exception->getMessage()); $maintenanceReady = false; $error = 'Database maintenance setup is incomplete. Apply the Phase 21 maintenance migration, then try again.'; }
$lastSuccess = null; foreach ($backups as $backup) { if ($backup['status'] === 'SUCCEEDED') { $lastSuccess = $backup; break; } }
try { $retentionDays = tuman_maintenance_positive_int('TUMAN_BACKUP_RETENTION_DAYS', 30); } catch (Throwable) { $retentionDays = null; }
tuman_admin_page_start('Backups and retention');
?>
<h1>Backups and retention</h1>
<p>Backups contain sensitive information and are stored in configured external backup storage. Keep that storage protected and separate from the web application.</p>
<?php if ($notice): ?><p role="status"><?= htmlspecialchars($notice, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
<?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
<?php if (!$maintenanceReady): tuman_admin_page_end(); exit; endif; ?>

<h2>Database backup</h2>
<p>Configured destination: secure external backup storage.<?php if ($retentionDays !== null): ?> Successful backup files are retained for <?= $retentionDays ?> days.<?php endif; ?></p>
<?php if ($lastSuccess): ?><p>Latest successful backup: <?= htmlspecialchars((string) $lastSuccess['completed_at'], ENT_QUOTES, 'UTF-8') ?> · <?= htmlspecialchars((string) $lastSuccess['storage_identifier'], ENT_QUOTES, 'UTF-8') ?> · <?= number_format((int) $lastSuccess['file_size_bytes']) ?> bytes.</p><?php else: ?><p>No successful backup has been recorded yet.</p><?php endif; ?>
<form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="action" value="backup"><p><button type="submit">Run backup now</button> <a class="button" href="/Tuman/admin/backup-diagnostic.php">Diagnose backup</a></p></form>
<div style="overflow-x:auto"><table><thead><tr><th>Started</th><th>Completed</th><th>Status</th><th>Identifier</th><th>Size</th><th>Result</th></tr></thead><tbody><?php foreach ($backups as $backup): ?><tr><td><?= htmlspecialchars((string) $backup['started_at'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) ($backup['completed_at'] ?? '—'), ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) $backup['status'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) ($backup['storage_identifier'] ?? '—'), ENT_QUOTES, 'UTF-8') ?></td><td><?= $backup['file_size_bytes'] === null ? '—' : number_format((int) $backup['file_size_bytes']) . ' bytes' ?></td><td><?= htmlspecialchars((string) ($backup['error_summary'] ?? 'Completed'), ENT_QUOTES, 'UTF-8') ?></td></tr><?php endforeach; ?><?php if ($backups === []): ?><tr><td colspan="6">No backup runs yet.</td></tr><?php endif; ?></tbody></table></div>

<h2>Purge old operational data</h2>
<p>Only email-delivery records and activity-log records created before the cutoff can be purged. User, teaching, attendance, batch, billing, invoice, payment, credit, refund, and other financial history are never purged by this feature.</p>
<form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="action" value="preview"><p><label>Delete records before <input type="date" name="cutoff_date" required value="<?= htmlspecialchars($cutoff, ENT_QUOTES, 'UTF-8') ?>"></label></p><p><button type="submit">Preview purge</button></p></form>
<?php if (is_array($preview)): ?><h3><?= $notice !== null && str_starts_with($notice, 'Eligible') ? 'Purge result' : 'Preview result' ?></h3><ul><?php foreach ($preview as $table => $count): ?><li><?= htmlspecialchars($table, ENT_QUOTES, 'UTF-8') ?>: <?= number_format($count) ?> record(s)</li><?php endforeach; ?></ul><?php endif; ?>
<form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><input type="hidden" name="action" value="purge"><p><label>Delete records before <input type="date" name="cutoff_date" required value="<?= htmlspecialchars($cutoff, ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Type PURGE to confirm <input name="confirmation" required autocomplete="off"></label></p><p>A new successful database backup will be made and verified before any eligible records are deleted.</p><p><button type="submit">Purge eligible data</button></p></form>
<div style="overflow-x:auto"><table><thead><tr><th>Started</th><th>Mode</th><th>Cutoff</th><th>Status</th><th>Backup</th><th>Rows</th><th>Result</th></tr></thead><tbody><?php foreach ($purges as $purge): $counts = $purge['row_counts_json'] ? json_decode((string) $purge['row_counts_json'], true) : []; ?><tr><td><?= htmlspecialchars((string) $purge['started_at'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) $purge['mode'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) $purge['cutoff_date'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) $purge['status'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars((string) ($purge['backup_identifier'] ?? '—'), ENT_QUOTES, 'UTF-8') ?></td><td><?php if (is_array($counts)): ?><?php foreach ($counts as $table => $count): ?><?= htmlspecialchars((string) $table, ENT_QUOTES, 'UTF-8') ?>: <?= (int) $count ?><br><?php endforeach; ?><?php endif; ?></td><td><?= htmlspecialchars((string) ($purge['error_summary'] ?? 'Completed'), ENT_QUOTES, 'UTF-8') ?></td></tr><?php endforeach; ?><?php if ($purges === []): ?><tr><td colspan="7">No purge runs yet.</td></tr><?php endif; ?></tbody></table></div>
<?php tuman_admin_page_end(); ?>
