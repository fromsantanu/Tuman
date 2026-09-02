<?php
declare(strict_types=1);

require_once __DIR__ . '/env.php';

/** Creates the application's PDO connection without exposing database details. */
function tuman_database(): PDO
{
    static $connection = null;
    if ($connection instanceof PDO) {
        return $connection;
    }

    $environment = tuman_environment();
    foreach (['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_CHARSET', 'DB_USER'] as $key) {
        if (!isset($environment[$key]) || $environment[$key] === '') {
            throw new RuntimeException('Database configuration is incomplete.');
        }
    }

    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=%s', $environment['DB_HOST'], $environment['DB_PORT'], $environment['DB_NAME'], $environment['DB_CHARSET']);

    try {
        $connection = new PDO($dsn, $environment['DB_USER'], $environment['DB_PASSWORD'] ?? '', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    } catch (PDOException $exception) {
        error_log('Tuman database connection failed: ' . $exception->getMessage());
        throw new RuntimeException('The application database is unavailable.');
    }

    return $connection;
}
