<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/services/maintenance.php';
$options = getopt('', ['cutoff:', 'preview', 'execute', 'scheduled']);
if (isset($options['scheduled'])) { $days = tuman_maintenance_positive_int('TUMAN_PURGE_RETENTION_DAYS', 365); $cutoff = (new DateTimeImmutable('today', new DateTimeZone('UTC')))->sub(new DateInterval('P' . $days . 'D'))->format('Y-m-d'); $execute = true; }
else { $cutoff = is_string($options['cutoff'] ?? null) ? $options['cutoff'] : ''; $execute = isset($options['execute']) && !isset($options['preview']); }
try { $database = tuman_database(); if ($execute) { $result = tuman_maintenance_execute_purge($database, null, $cutoff); fwrite(STDOUT, 'Purge succeeded: ' . json_encode($result['counts']) . "\n"); } else { $counts = tuman_maintenance_preview_purge($database, $cutoff); fwrite(STDOUT, 'Preview: ' . json_encode($counts) . "\n"); } exit(0); }
catch (Throwable $exception) { error_log('Tuman scheduled purge failed: ' . $exception->getMessage()); fwrite(STDERR, "Purge failed. Check the server log and configuration.\n"); exit(1); }
