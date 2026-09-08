<?php
declare(strict_types=1);

/*
 * Run only from cPanel Terminal/SSH:
 *     php bin/diagnose-backup.php
 *
 * This does not create a retained backup or alter the database. It writes a
 * temporary dump solely to test the same steps used by the backup feature and
 * removes it before exiting. Do not expose this script through the web server.
 */
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/services/maintenance.php';

function tuman_diagnostic_line(string $message): void
{
    fwrite(STDOUT, $message . PHP_EOL);
}

/** Prevent an unexpected dump-tool message from revealing a password. */
function tuman_diagnostic_message(string $message): string
{
    $message = preg_replace('/(password\s*[=:]\s*)\S+/i', '$1[redacted]', trim($message)) ?? '';
    return $message === '' ? '(no diagnostic output)' : $message;
}

$clientFile = null;
$temporaryDump = null;

try {
    tuman_diagnostic_line('Checking backup directory...');
    $directory = tuman_maintenance_backup_directory();
    tuman_diagnostic_line('OK: backup directory is available and writable.');

    tuman_diagnostic_line('Checking database connection...');
    $database = tuman_database();
    $database->query('SELECT 1');
    tuman_diagnostic_line('OK: database connection succeeded.');

    $configuration = tuman_maintenance_database_configuration();
    tuman_diagnostic_line('Checking mysqldump program...');
    $binary = tuman_maintenance_dump_binary();
    tuman_diagnostic_line('OK: configured mysqldump program exists.');

    $clientFile = tuman_maintenance_write_client_file($configuration);
    $temporaryDump = $directory . DIRECTORY_SEPARATOR . '.tuman-backup-diagnostic-' . bin2hex(random_bytes(6)) . '.sql';
    $command = [
        $binary,
        '--defaults-extra-file=' . $clientFile,
        '--single-transaction', '--routines', '--events', '--triggers',
        '--add-drop-table', '--add-drop-trigger', '--no-tablespaces',
        '--databases', $configuration['DB_NAME'], '--result-file=' . $temporaryDump,
    ];

    tuman_diagnostic_line('Running mysqldump test...');
    $pipes = [];
    $process = proc_open($command, [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
    if (!is_resource($process)) {
        throw new RuntimeException('mysqldump could not be started.');
    }
    $standardOutput = stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $standardError = stream_get_contents($pipes[2]);
    fclose($pipes[2]);
    $exitCode = proc_close($process);
    if ($exitCode !== 0 || !is_file($temporaryDump) || filesize($temporaryDump) < 32) {
        $detail = tuman_diagnostic_message($standardError . "\n" . $standardOutput);
        throw new RuntimeException('mysqldump failed (exit code ' . $exitCode . '): ' . $detail);
    }
    tuman_diagnostic_line('OK: mysqldump created a database dump.');

    tuman_diagnostic_line('Verifying generated dump...');
    tuman_maintenance_verify_dump($database, $configuration['DB_NAME'], $temporaryDump);
    tuman_diagnostic_line('OK: dump verification passed. The production backup should succeed.');
    exit(0);
} catch (Throwable $exception) {
    fwrite(STDERR, 'BACKUP DIAGNOSTIC FAILED: ' . tuman_diagnostic_message($exception->getMessage()) . PHP_EOL);
    exit(1);
} finally {
    if (is_string($clientFile) && is_file($clientFile)) {
        @unlink($clientFile);
    }
    if (is_string($temporaryDump) && is_file($temporaryDump)) {
        @unlink($temporaryDump);
    }
}
