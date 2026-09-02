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
    fwrite(STDERR, "Database connection verification failed: {$exception->getMessage()}\n");
    exit(1);
}
