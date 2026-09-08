<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';

try {
    $row = tuman_database()->query('SELECT 1 AS connected')->fetch();
    if (($row['connected'] ?? null) !== 1) {
        throw new RuntimeException('Unexpected connection test result.');
    }
    echo "Database connection verified.\n";
} catch (Throwable $exception) {
    http_response_code(500);
    echo 'Database connection verification failed: ' . htmlspecialchars($exception->getMessage(), ENT_QUOTES, 'UTF-8');
    exit(1);
}
