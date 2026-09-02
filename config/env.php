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
        $values = parse_ini_file($path, false, INI_SCANNER_RAW);
        if ($values === false) {
            throw new RuntimeException('Application configuration could not be read.');
        }

        foreach ($values as $key => $value) {
            $environment[(string) $key] = (string) $value;
        }
    }

    return $environment;
}
