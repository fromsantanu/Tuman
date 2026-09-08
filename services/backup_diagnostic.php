<?php
declare(strict_types=1);

require_once __DIR__ . '/maintenance.php';

/** @return list<string> Safe, administrator-facing results from a temporary backup test. */
function tuman_backup_diagnostic_run(): array
{
    $clientFile = null;
    $temporaryDump = null;
    $results = [];
    try {
        $directory = tuman_maintenance_backup_directory();
        $results[] = 'Backup directory is available and writable.';

        $database = tuman_database();
        $database->query('SELECT 1');
        $results[] = 'Database connection succeeded.';

        $configuration = tuman_maintenance_database_configuration();
        $binary = tuman_maintenance_dump_binary();
        $results[] = 'Configured mysqldump program exists.';

        $clientFile = tuman_maintenance_write_client_file($configuration);
        $temporaryDump = $directory . DIRECTORY_SEPARATOR . '.tuman-backup-diagnostic-' . bin2hex(random_bytes(6)) . '.sql';
        $command = [$binary, '--defaults-extra-file=' . $clientFile, '--single-transaction', '--routines', '--events', '--triggers', '--add-drop-table', '--add-drop-trigger', '--no-tablespaces', '--databases', $configuration['DB_NAME'], '--result-file=' . $temporaryDump];
        $pipes = [];
        $process = proc_open($command, [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        if (!is_resource($process)) { throw new RuntimeException('mysqldump could not be started.'); }
        $standardOutput = stream_get_contents($pipes[1]); fclose($pipes[1]);
        $standardError = stream_get_contents($pipes[2]); fclose($pipes[2]);
        $exitCode = proc_close($process);
        if ($exitCode !== 0 || !is_file($temporaryDump) || filesize($temporaryDump) < 32) {
            $detail = preg_replace('/(password\s*[=:]\s*)\S+/i', '$1[redacted]', trim($standardError . "\n" . $standardOutput)) ?? '';
            throw new RuntimeException('mysqldump failed (exit code ' . $exitCode . '): ' . ($detail === '' ? 'no diagnostic output' : $detail));
        }
        $results[] = 'mysqldump created a temporary database dump.';

        tuman_maintenance_verify_dump($database, $configuration['DB_NAME'], $temporaryDump);
        $results[] = 'Dump verification passed. The production backup should succeed.';
        return $results;
    } finally {
        if (is_string($clientFile) && is_file($clientFile)) { @unlink($clientFile); }
        if (is_string($temporaryDump) && is_file($temporaryDump)) { @unlink($temporaryDump); }
    }
}
