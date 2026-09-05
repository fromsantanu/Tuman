<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/services/maintenance.php';
try { $result = tuman_maintenance_run_backup(tuman_database()); fwrite(STDOUT, "Backup succeeded: {$result['identifier']}\n"); exit(0); }
catch (Throwable $exception) { error_log('Tuman scheduled backup failed: ' . $exception->getMessage()); fwrite(STDERR, "Backup failed. Check the server log and configuration.\n"); exit(1); }
