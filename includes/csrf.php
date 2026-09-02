<?php
declare(strict_types=1);

require_once __DIR__ . '/session.php';

function tuman_csrf_token(): string
{
    tuman_start_session();
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['csrf_token'];
}

function tuman_csrf_is_valid(?string $token): bool
{
    tuman_start_session();
    return is_string($token)
        && isset($_SESSION['csrf_token'])
        && hash_equals($_SESSION['csrf_token'], $token);
}

function tuman_require_csrf(): void
{
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) {
        http_response_code(400);
        exit('Your request could not be verified. Please try again.');
    }
}
