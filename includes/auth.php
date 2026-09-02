<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/config/database.php';
require_once __DIR__ . '/session.php';

const TUMAN_ROLES = ['ADMIN', 'TEACHER', 'STUDENT'];
const TUMAN_DUMMY_PASSWORD_HASH = '$2y$10$o59AZt0MojeBRu96xwedSuvtbMKFn14cyl5rCn0VGju/egbF.oE12';

/** @return array{id: int, role: string}|null */
function tuman_authenticate(string $username, string $password): ?array
{
    if ($username === '' || strlen($username) > 50 || $password === '') {
        return null;
    }
    try {
        $statement = tuman_database()->prepare('SELECT id, password_hash, role, status FROM tmn_users WHERE username = :username LIMIT 1');
        $statement->execute(['username' => $username]);
        $user = $statement->fetch();
    } catch (Throwable $exception) {
        error_log('Tuman login lookup failed: ' . $exception->getMessage());
        throw new RuntimeException('Authentication is temporarily unavailable.');
    }

    // Verify a fixed non-user hash for an unknown name to limit timing differences.
    $passwordHash = is_array($user) ? $user['password_hash'] : TUMAN_DUMMY_PASSWORD_HASH;
    // PHP's verifier receives the database hash only; plaintext passwords are never retained.
    if (!is_array($user) || !password_verify($password, $passwordHash)) {
        return null;
    }
    if ($user['status'] !== 'ACTIVE' || !in_array($user['role'], TUMAN_ROLES, true)) {
        return null;
    }

    try {
        $statement = tuman_database()->prepare('UPDATE tmn_users SET last_login_at = UTC_TIMESTAMP() WHERE id = :id');
        $statement->execute(['id' => $user['id']]);
    } catch (Throwable $exception) {
        error_log('Tuman last-login update failed: ' . $exception->getMessage());
        throw new RuntimeException('Authentication is temporarily unavailable.');
    }
    return ['id' => (int) $user['id'], 'role' => $user['role']];
}

function tuman_login(array $identity): void
{
    tuman_start_session();
    session_regenerate_id(true);
    $_SESSION['user_id'] = $identity['id'];
    $_SESSION['role'] = $identity['role'];
}

function tuman_logout(): void
{
    tuman_start_session();
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();
}

/** @return array{id: int, role: string}|null */
function tuman_current_user(): ?array
{
    tuman_start_session();
    if (!isset($_SESSION['user_id'], $_SESSION['role']) || !is_int($_SESSION['user_id']) || !in_array($_SESSION['role'], TUMAN_ROLES, true)) {
        return null;
    }
    return ['id' => $_SESSION['user_id'], 'role' => $_SESSION['role']];
}

function tuman_redirect_to_login(): void
{
    header('Location: /Tuman/public/login.php');
    exit;
}

/** @return array{id: int, role: string} */
function tuman_require_role(string $role): array
{
    $user = tuman_current_user();
    if ($user === null) {
        tuman_redirect_to_login();
    }
    if ($user['role'] !== $role) {
        http_response_code(403);
        exit('You do not have permission to access this page.');
    }
    return $user;
}

function tuman_role_home(string $role): string
{
    return match ($role) {
        'ADMIN' => '/Tuman/admin/index.php',
        'TEACHER' => '/Tuman/teacher/index.php',
        'STUDENT' => '/Tuman/student/index.php',
        default => '/Tuman/public/login.php',
    };
}
