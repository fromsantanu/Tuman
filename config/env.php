<?php
declare(strict_types=1);

/**
 * Loads local environment values once. The real .env file is ignored by Git so
 * database credentials never need to appear in PHP source code.
 *
 * @return array<string, string>
 */
function tuman_environment(): array
{
    static $environment = null;

    if ($environment !== null) {
        return $environment;
    }

    $environment = [];
    $path = dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env';

    if (is_file($path)) {
        $lines = file($path, FILE_IGNORE_NEW_LINES);
        if ($lines === false) {
            throw new RuntimeException('Application configuration could not be read.');
        }

        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '' || str_starts_with($line, '#') || str_starts_with($line, ';')) {
                continue;
            }

            $separator = strpos($line, '=');
            if ($separator === false) {
                continue;
            }

            $key = trim(substr($line, 0, $separator));
            $value = trim(substr($line, $separator + 1));
            if ($key === '') {
                continue;
            }

            if (strlen($value) >= 2 && (($value[0] === '"' && $value[-1] === '"') || ($value[0] === "'" && $value[-1] === "'"))) {
                $value = substr($value, 1, -1);
            }

            $environment[$key] = $value;
        }
    }

    return $environment;
}
