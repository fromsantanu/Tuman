<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once __DIR__ . '/activity_log.php';

function tuman_admin_error(string $message): void { throw new InvalidArgumentException($message); }

/** @return array<string, string> */
function tuman_validate_user_input(string $username, string $email, string $role): array
{
    $errors = [];
    if ($username === '' || strlen($username) > 50) { $errors['username'] = 'Username is required and must be 50 characters or fewer.'; }
    if ($email !== '' && (strlen($email) > 254 || filter_var($email, FILTER_VALIDATE_EMAIL) === false)) { $errors['email'] = 'Enter a valid email address or leave it blank.'; }
    if (!in_array($role, TUMAN_ROLES, true)) { $errors['role'] = 'Choose a valid user role.'; }
    return $errors;
}

/** @return array<string, mixed>|null */
function tuman_admin_user(PDO $database, int $id): ?array
{
    $statement = $database->prepare('SELECT id, username, email, role, status, created_at, updated_at, last_login_at FROM tmn_users WHERE id = :id');
    $statement->execute(['id' => $id]); $user = $statement->fetch(); return is_array($user) ? $user : null;
}

/** @return list<array<string, mixed>> */
function tuman_admin_users(PDO $database): array
{
    return $database->query('SELECT id, username, email, role, status, created_at, last_login_at FROM tmn_users ORDER BY created_at DESC, id DESC')->fetchAll();
}

function tuman_admin_create_user(PDO $database, int $actorId, string $username, string $email, string $role, string $password): void
{
    $errors = tuman_validate_user_input($username, $email, $role);
    if (strlen($password) < 12) { $errors['password'] = 'Password must be at least 12 characters long.'; }
    if ($errors !== []) { tuman_admin_error(reset($errors)); }
    try {
        $statement = $database->prepare("INSERT INTO tmn_users (username, password_hash, email, role, status) VALUES (:username, :password_hash, :email, :role, 'ACTIVE')");
        $statement->execute(['username' => $username, 'password_hash' => password_hash($password, PASSWORD_DEFAULT), 'email' => $email === '' ? null : $email, 'role' => $role]);
        $id = (int) $database->lastInsertId(); tuman_log_activity($database, $actorId, 'USER_CREATED', 'USER', $id, ['username' => $username, 'role' => $role]);
    } catch (PDOException $exception) {
        if ($exception->getCode() === '23000') { tuman_admin_error('That username or email address is already in use.'); }
        throw $exception;
    }
}

function tuman_admin_update_user(PDO $database, int $actorId, int $userId, string $username, string $email, string $role): void
{
    $errors = tuman_validate_user_input($username, $email, $role); if ($errors !== []) { tuman_admin_error(reset($errors)); }
    $database->beginTransaction();
    try {
        $target = tuman_admin_user($database, $userId); if ($target === null) { tuman_admin_error('User not found.'); }
        if ($actorId === $userId && $role !== 'ADMIN') { tuman_admin_error('You cannot remove your own Administrator role.'); }
        if ($target['role'] === 'ADMIN' && $target['status'] === 'ACTIVE' && $role !== 'ADMIN') {
            $activeAdmins = $database->query("SELECT id FROM tmn_users WHERE role = 'ADMIN' AND status = 'ACTIVE' FOR UPDATE")->fetchAll();
            if (count($activeAdmins) <= 1) { tuman_admin_error('The final active Administrator cannot be demoted.'); }
        }
        $statement = $database->prepare('UPDATE tmn_users SET username = :username, email = :email, role = :role WHERE id = :id');
        $statement->execute(['username' => $username, 'email' => $email === '' ? null : $email, 'role' => $role, 'id' => $userId]);
        tuman_log_activity($database, $actorId, 'USER_UPDATED', 'USER', $userId, ['username' => $username]);
        if ($target['role'] !== $role) { tuman_log_activity($database, $actorId, 'USER_ROLE_CHANGED', 'USER', $userId, ['from' => $target['role'], 'to' => $role]); }
        $database->commit();
    } catch (Throwable $exception) {
        if ($database->inTransaction()) { $database->rollBack(); }
        if ($exception instanceof PDOException && $exception->getCode() === '23000') { tuman_admin_error('That username or email address is already in use.'); }
        throw $exception;
    }
}

function tuman_admin_set_user_status(PDO $database, int $actorId, int $userId, string $status): void
{
    if (!in_array($status, ['ACTIVE', 'INACTIVE'], true)) { tuman_admin_error('Choose a valid account status.'); }
    $database->beginTransaction();
    try {
        $target = tuman_admin_user($database, $userId); if ($target === null) { tuman_admin_error('User not found.'); }
        if ($actorId === $userId && $status === 'INACTIVE') { tuman_admin_error('You cannot deactivate your own account.'); }
        if ($target['role'] === 'ADMIN' && $target['status'] === 'ACTIVE' && $status === 'INACTIVE') {
            $activeAdmins = $database->query("SELECT id FROM tmn_users WHERE role = 'ADMIN' AND status = 'ACTIVE' FOR UPDATE")->fetchAll();
            if (count($activeAdmins) <= 1) { tuman_admin_error('The final active Administrator cannot be deactivated.'); }
        }
        $statement = $database->prepare('UPDATE tmn_users SET status = :status WHERE id = :id'); $statement->execute(['status' => $status, 'id' => $userId]);
        tuman_log_activity($database, $actorId, 'USER_STATUS_CHANGED', 'USER', $userId, ['from' => $target['status'], 'to' => $status]); $database->commit();
    } catch (Throwable $exception) { if ($database->inTransaction()) { $database->rollBack(); } throw $exception; }
}

function tuman_admin_reset_password(PDO $database, int $actorId, int $userId, string $password, string $confirmation): void
{
    if (strlen($password) < 12) { tuman_admin_error('Password must be at least 12 characters long.'); }
    if (!hash_equals($password, $confirmation)) { tuman_admin_error('Password confirmation does not match.'); }
    if (tuman_admin_user($database, $userId) === null) { tuman_admin_error('User not found.'); }
    $statement = $database->prepare('UPDATE tmn_users SET password_hash = :password_hash WHERE id = :id');
    $statement->execute(['password_hash' => password_hash($password, PASSWORD_DEFAULT), 'id' => $userId]); tuman_log_activity($database, $actorId, 'USER_PASSWORD_RESET', 'USER', $userId);
}
