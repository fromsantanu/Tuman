<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/env.php';
require_once __DIR__ . '/activity_log.php';

const TUMAN_MAINTENANCE_TABLES = ['tmn_email_log' => 'created_at', 'tmn_activity_log' => 'created_at'];

function tuman_maintenance_error(string $message): void { throw new InvalidArgumentException($message); }

function tuman_maintenance_date(string $date): string
{
    $value = DateTimeImmutable::createFromFormat('!Y-m-d', $date, new DateTimeZone('UTC'));
    $errors = DateTimeImmutable::getLastErrors();
    if ($value === false || ($errors !== false && ($errors['warning_count'] || $errors['error_count'])) || $value->format('Y-m-d') !== $date) {
        tuman_maintenance_error('Choose a valid cutoff date.');
    }
    return $date;
}

function tuman_maintenance_positive_int(string $key, int $default): int
{
    $value = tuman_environment()[$key] ?? (string) $default;
    $number = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'max_range' => 36500]]);
    if ($number === false) { throw new RuntimeException('Maintenance configuration is invalid.'); }
    return (int) $number;
}

function tuman_maintenance_is_absolute_path(string $path): bool
{
    return (bool) preg_match('/^(?:[A-Za-z]:[\\\\\/]|\\\\|\/)/', $path);
}

function tuman_maintenance_backup_directory(): string
{
    $directory = trim(tuman_environment()['TUMAN_BACKUP_DIR'] ?? '');
    if ($directory === '' || !tuman_maintenance_is_absolute_path($directory)) {
        throw new RuntimeException('Backup storage configuration is incomplete.');
    }
    $directory = rtrim($directory, "\\/");
    $application = realpath(dirname(__DIR__));
    $resolved = realpath($directory);
    if ($resolved !== false && $application !== false && str_starts_with(strtolower($resolved), strtolower($application . DIRECTORY_SEPARATOR))) {
        throw new RuntimeException('Backup storage must be outside the application directory.');
    }
    if (!is_dir($directory) && !mkdir($directory, 0700, true) && !is_dir($directory)) {
        throw new RuntimeException('Secure backup storage is unavailable.');
    }
    if (!is_writable($directory)) { throw new RuntimeException('Secure backup storage is unavailable.'); }
    return $directory;
}

function tuman_maintenance_dump_binary(): string
{
    $binary = trim(tuman_environment()['TUMAN_MYSQLDUMP_PATH'] ?? 'mysqldump');
    if ($binary === '' || str_contains($binary, "\0")) { throw new RuntimeException('Database dump configuration is invalid.'); }
    if (str_contains($binary, '/') || str_contains($binary, '\\')) {
        if (!tuman_maintenance_is_absolute_path($binary) || !is_file($binary)) { throw new RuntimeException('Database dump configuration is invalid.'); }
    } elseif (!in_array(strtolower($binary), ['mysqldump', 'mysqldump.exe'], true)) { throw new RuntimeException('Database dump configuration is invalid.'); }
    return $binary;
}

/** @return array<string,string> */
function tuman_maintenance_database_configuration(): array
{
    $environment = tuman_environment();
    foreach (['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER'] as $key) {
        if (!isset($environment[$key]) || $environment[$key] === '') { throw new RuntimeException('Database configuration is incomplete.'); }
    }
    if (!preg_match('/^[A-Za-z0-9_]+$/', $environment['DB_NAME'])) { throw new RuntimeException('Database name configuration is invalid.'); }
    return $environment;
}

function tuman_maintenance_create_backup_run(PDO $database, ?int $actorId): int
{
    $statement = $database->prepare('INSERT INTO tmn_backup_runs (initiated_by_user_id, status, started_at) VALUES (:actor, \'RUNNING\', UTC_TIMESTAMP())');
    $statement->execute(['actor' => $actorId]);
    return (int) $database->lastInsertId();
}

function tuman_maintenance_finish_backup_run(PDO $database, int $id, bool $success, ?string $identifier = null, ?int $size = null): void
{
    $statement = $database->prepare('UPDATE tmn_backup_runs SET status=:status, storage_identifier=:identifier, file_size_bytes=:size, error_summary=:error, completed_at=UTC_TIMESTAMP() WHERE id=:id');
    $statement->execute(['status' => $success ? 'SUCCEEDED' : 'FAILED', 'identifier' => $identifier, 'size' => $size, 'error' => $success ? null : 'Backup did not complete. Check the server log and configuration.', 'id' => $id]);
}

function tuman_maintenance_write_client_file(array $configuration): string
{
    $path = tempnam(sys_get_temp_dir(), 'tmn-db-');
    if ($path === false) { throw new RuntimeException('Unable to prepare database backup.'); }
    $content = "[client]\nhost=" . $configuration['DB_HOST'] . "\nport=" . $configuration['DB_PORT'] . "\nuser=" . $configuration['DB_USER'] . "\npassword=" . ($configuration['DB_PASSWORD'] ?? '') . "\n";
    if (file_put_contents($path, $content, LOCK_EX) === false) { @unlink($path); throw new RuntimeException('Unable to prepare database backup.'); }
    @chmod($path, 0600);
    return $path;
}

function tuman_maintenance_gzip(string $source, string $destination): void
{
    $input = fopen($source, 'rb'); $output = gzopen($destination, 'wb9');
    if ($input === false || $output === false) { if (is_resource($input)) { fclose($input); } throw new RuntimeException('Unable to compress database backup.'); }
    try { while (!feof($input)) { $chunk = fread($input, 1048576); if ($chunk === false || gzwrite($output, $chunk) === false) { throw new RuntimeException('Unable to compress database backup.'); } } }
    finally { fclose($input); gzclose($output); }
}

function tuman_maintenance_verify_dump(PDO $database, string $schema, string $dumpPath): void
{
    $dump = file_get_contents($dumpPath);
    if ($dump === false || !str_contains($dump, 'CREATE DATABASE')) { throw new RuntimeException('Database backup verification failed.'); }
    $objects = [
        ['sql' => 'SELECT TABLE_NAME AS name,TABLE_TYPE AS type FROM information_schema.TABLES WHERE TABLE_SCHEMA=:schema', 'kind' => 'table'],
        ['sql' => 'SELECT TRIGGER_NAME AS name FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=:schema', 'kind' => 'trigger'],
        ['sql' => 'SELECT ROUTINE_NAME AS name,ROUTINE_TYPE AS type FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=:schema', 'kind' => 'routine'],
        ['sql' => 'SELECT EVENT_NAME AS name FROM information_schema.EVENTS WHERE EVENT_SCHEMA=:schema', 'kind' => 'event'],
    ];
    foreach ($objects as $object) {
        $statement = $database->prepare($object['sql']); $statement->execute(['schema' => $schema]);
        foreach ($statement->fetchAll() as $row) {
            $name = preg_quote((string)$row['name'], '/');
            $pattern = match ($object['kind']) {
                'table' => (($row['type'] ?? '') === 'VIEW' ? '/CREATE(?:\\s+ALGORITHM=\\S+)?(?:\\s+DEFINER\\s*=\\s*\\S+)?(?:\\s+SQL\\s+SECURITY\\s+\\w+)?\\s+VIEW\\s+`?' : '/CREATE\\s+TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?`?') . $name . '`?/is',
                'trigger' => '/TRIGGER\\s+`?' . $name . '`?/i',
                'routine' => '/' . (($row['type'] ?? '') === 'FUNCTION' ? 'FUNCTION' : 'PROCEDURE') . '\\s+`?' . $name . '`?/i',
                'event' => '/EVENT\\s+`?' . $name . '`?/i',
            };
            if (preg_match($pattern, $dump) !== 1) { throw new RuntimeException('Database backup verification failed.'); }
        }
    }
}

/** @return array{id:int,identifier:string,size:int} */
function tuman_maintenance_run_backup(PDO $database, ?int $actorId = null): array
{
    $runId = tuman_maintenance_create_backup_run($database, $actorId);
    $partialSql = null; $partialGzip = null; $clientFile = null;
    try {
        $directory = tuman_maintenance_backup_directory(); $configuration = tuman_maintenance_database_configuration();
        $stamp = gmdate('Ymd-His') . '-' . bin2hex(random_bytes(6));
        $identifier = 'tuman-' . $stamp . '.sql.gz';
        $partialSql = $directory . DIRECTORY_SEPARATOR . 'tuman-' . $stamp . '.sql.partial';
        $partialGzip = $directory . DIRECTORY_SEPARATOR . $identifier . '.partial';
        $clientFile = tuman_maintenance_write_client_file($configuration);
        $command = [tuman_maintenance_dump_binary(), '--defaults-extra-file=' . $clientFile, '--single-transaction', '--routines', '--events', '--triggers', '--add-drop-table', '--add-drop-trigger', '--no-tablespaces', '--databases', $configuration['DB_NAME'], '--result-file=' . $partialSql];
        $pipes = [];
        $process = proc_open($command, [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        if (!is_resource($process)) { throw new RuntimeException('Unable to start database backup.'); }
        foreach ($pipes as $pipe) { stream_get_contents($pipe); fclose($pipe); }
        if (proc_close($process) !== 0 || !is_file($partialSql) || filesize($partialSql) < 32) { throw new RuntimeException('Database backup failed.'); }
        tuman_maintenance_verify_dump($database, $configuration['DB_NAME'], $partialSql);
        tuman_maintenance_gzip($partialSql, $partialGzip);
        if (!is_file($partialGzip) || filesize($partialGzip) < 32 || !rename($partialGzip, $directory . DIRECTORY_SEPARATOR . $identifier)) { throw new RuntimeException('Database backup failed.'); }
        $size = filesize($directory . DIRECTORY_SEPARATOR . $identifier); if ($size === false) { throw new RuntimeException('Database backup failed.'); }
        tuman_maintenance_finish_backup_run($database, $runId, true, $identifier, (int) $size);
        if ($actorId !== null) { tuman_log_activity($database, $actorId, 'maintenance_backup_succeeded', 'BACKUP_RUN', $runId, ['identifier' => $identifier, 'size_bytes' => (int) $size]); }
        tuman_maintenance_prune_backups($database, $directory);
        return ['id' => $runId, 'identifier' => $identifier, 'size' => (int) $size];
    } catch (Throwable $exception) {
        foreach ([$partialSql, $partialGzip] as $file) { if (is_string($file) && is_file($file)) { @unlink($file); } }
        tuman_maintenance_finish_backup_run($database, $runId, false);
        if ($actorId !== null) { tuman_log_activity($database, $actorId, 'maintenance_backup_failed', 'BACKUP_RUN', $runId); }
        error_log('Tuman backup failed: ' . $exception->getMessage());
        throw new RuntimeException('The database backup could not be completed.');
    } finally { if (is_string($clientFile) && is_file($clientFile)) { @unlink($clientFile); } if (is_string($partialSql) && is_file($partialSql)) { @unlink($partialSql); } }
}

function tuman_maintenance_prune_backups(PDO $database, string $directory): void
{
    $days = tuman_maintenance_positive_int('TUMAN_BACKUP_RETENTION_DAYS', 30);
    $cutoff = (new DateTimeImmutable('now', new DateTimeZone('UTC')))->sub(new DateInterval('P' . $days . 'D'))->format('Y-m-d H:i:s');
    $statement = $database->prepare("SELECT id, storage_identifier FROM tmn_backup_runs WHERE status='SUCCEEDED' AND completed_at < :cutoff ORDER BY completed_at ASC");
    $statement->execute(['cutoff' => $cutoff]);
    foreach ($statement->fetchAll() as $row) {
        $name = (string) $row['storage_identifier'];
        if (preg_match('/^tuman-[0-9]{8}-[0-9]{6}-[a-f0-9]{12}\\.sql\\.gz$/', $name) === 1) { @unlink($directory . DIRECTORY_SEPARATOR . $name); }
    }
}

/** @return array<string,int> */
function tuman_maintenance_preview_purge(PDO $database, string $cutoff): array
{
    $cutoff = tuman_maintenance_date($cutoff); $counts = [];
    foreach (TUMAN_MAINTENANCE_TABLES as $table => $column) { $statement = $database->prepare("SELECT COUNT(*) FROM {$table} WHERE {$column} < :cutoff"); $statement->execute(['cutoff' => $cutoff]); $counts[$table] = (int) $statement->fetchColumn(); }
    return $counts;
}

function tuman_maintenance_create_purge_run(PDO $database, ?int $actorId, string $mode, string $cutoff): int
{
    $statement = $database->prepare('INSERT INTO tmn_purge_runs (initiated_by_user_id, mode, cutoff_date, status, started_at) VALUES (:actor,:mode,:cutoff,\'RUNNING\',UTC_TIMESTAMP())');
    $statement->execute(['actor' => $actorId, 'mode' => $mode, 'cutoff' => $cutoff]); return (int) $database->lastInsertId();
}

function tuman_maintenance_finish_purge_run(PDO $database, int $id, bool $success, array $counts = [], ?int $backupId = null): void
{
    $statement = $database->prepare('UPDATE tmn_purge_runs SET backup_run_id=:backup, status=:status, row_counts_json=:counts, error_summary=:error, completed_at=UTC_TIMESTAMP() WHERE id=:id');
    $statement->execute(['backup' => $backupId, 'status' => $success ? 'SUCCEEDED' : 'FAILED', 'counts' => $counts === [] ? null : json_encode($counts, JSON_THROW_ON_ERROR), 'error' => $success ? null : 'Purge did not complete. Check the server log.', 'id' => $id]);
}

/** @return array{id:int,counts:array<string,int>} */
function tuman_maintenance_record_preview(PDO $database, ?int $actorId, string $cutoff): array
{
    $counts = tuman_maintenance_preview_purge($database, $cutoff); $id = tuman_maintenance_create_purge_run($database, $actorId, 'PREVIEW', $cutoff);
    tuman_maintenance_finish_purge_run($database, $id, true, $counts);
    if ($actorId !== null) { tuman_log_activity($database, $actorId, 'maintenance_purge_previewed', 'PURGE_RUN', $id, ['cutoff_date' => $cutoff, 'counts' => $counts]); }
    return ['id' => $id, 'counts' => $counts];
}

/** @return array{id:int,counts:array<string,int>,backup_id:int} */
function tuman_maintenance_execute_purge(PDO $database, ?int $actorId, string $cutoff): array
{
    $cutoff = tuman_maintenance_date($cutoff); $id = tuman_maintenance_create_purge_run($database, $actorId, 'EXECUTED', $cutoff); $counts = [];
    try {
        $backup = tuman_maintenance_run_backup($database, $actorId);
        foreach (TUMAN_MAINTENANCE_TABLES as $table => $column) {
            $counts[$table] = 0;
            do { $database->beginTransaction(); try { $delete = $database->prepare("DELETE FROM {$table} WHERE {$column} < :cutoff LIMIT 500"); $delete->execute(['cutoff' => $cutoff]); $deleted = $delete->rowCount(); $database->commit(); $counts[$table] += $deleted; } catch (Throwable $exception) { if ($database->inTransaction()) { $database->rollBack(); } throw $exception; } } while ($deleted === 500);
        }
        tuman_maintenance_finish_purge_run($database, $id, true, $counts, $backup['id']);
        if ($actorId !== null) { tuman_log_activity($database, $actorId, 'maintenance_purge_completed', 'PURGE_RUN', $id, ['cutoff_date' => $cutoff, 'counts' => $counts, 'backup_run_id' => $backup['id']]); }
        return ['id' => $id, 'counts' => $counts, 'backup_id' => $backup['id']];
    } catch (Throwable $exception) { tuman_maintenance_finish_purge_run($database, $id, false, $counts); error_log('Tuman purge failed: ' . $exception->getMessage()); throw new RuntimeException('The retention purge could not be completed.'); }
}

function tuman_maintenance_recent_backups(PDO $database): array { return $database->query('SELECT id,status,storage_identifier,file_size_bytes,error_summary,started_at,completed_at FROM tmn_backup_runs ORDER BY id DESC LIMIT 10')->fetchAll(); }
function tuman_maintenance_recent_purges(PDO $database): array { return $database->query('SELECT p.*,b.storage_identifier AS backup_identifier FROM tmn_purge_runs p LEFT JOIN tmn_backup_runs b ON b.id=p.backup_run_id ORDER BY p.id DESC LIMIT 10')->fetchAll(); }
