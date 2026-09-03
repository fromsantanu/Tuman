<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once __DIR__ . '/activity_log.php';

/** @return array<string, mixed>|null */
function tuman_profile(PDO $database, int $userId, string $role): ?array
{
    $tables = ['ADMIN' => 'tmn_admin_profiles', 'TEACHER' => 'tmn_teacher_profiles', 'STUDENT' => 'tmn_student_profiles'];
    if (!isset($tables[$role])) { return null; }
    $statement = $database->prepare("SELECT u.username, u.email, p.* FROM tmn_users u LEFT JOIN {$tables[$role]} p ON p.user_id=u.id WHERE u.id=:id AND u.role=:role");
    $statement->execute(['id' => $userId, 'role' => $role]);
    $profile = $statement->fetch();
    return is_array($profile) ? $profile : null;
}

/** @return array<string, string> */
function tuman_profile_values(array $input): array
{
    $fields = ['first_name', 'last_name', 'email', 'phone', 'address_line1', 'address_line2', 'city', 'state_name', 'postal_code', 'profile_details'];
    $values = [];
    foreach ($fields as $field) { $values[$field] = trim((string) ($input[$field] ?? '')); }
    if ($values['first_name'] === '' || strlen($values['first_name']) > 100) { throw new InvalidArgumentException('First name is required and must be 100 characters or fewer.'); }
    if (strlen($values['last_name']) > 100 || strlen($values['phone']) > 30 || strlen($values['email']) > 254 || strlen($values['profile_details']) > 5000) { throw new InvalidArgumentException('One or more profile fields are too long.'); }
    if ($values['email'] !== '' && filter_var($values['email'], FILTER_VALIDATE_EMAIL) === false) { throw new InvalidArgumentException('Enter a valid email address.'); }
    return $values;
}

function tuman_profile_photo(array $upload): ?string
{
    if (($upload['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) { return null; }
    if (($upload['error'] ?? UPLOAD_ERR_OK) !== UPLOAD_ERR_OK || !is_uploaded_file((string) ($upload['tmp_name'] ?? ''))) { throw new InvalidArgumentException('The profile photo could not be uploaded.'); }
    if ((int) ($upload['size'] ?? 0) > 2 * 1024 * 1024) { throw new InvalidArgumentException('Profile photos must be 2 MB or smaller.'); }
    $mime = (new finfo(FILEINFO_MIME_TYPE))->file((string) $upload['tmp_name']);
    $extensions = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    if (!isset($extensions[$mime])) { throw new InvalidArgumentException('Use a JPG, PNG, or WebP profile photo.'); }
    $directory = dirname(__DIR__) . '/uploads/profile-photos';
    if (!is_dir($directory) && !mkdir($directory, 0755, true) && !is_dir($directory)) { throw new RuntimeException('Profile-photo storage is unavailable.'); }
    $filename = bin2hex(random_bytes(20)) . '.' . $extensions[$mime];
    if (!move_uploaded_file((string) $upload['tmp_name'], $directory . '/' . $filename)) { throw new RuntimeException('The profile photo could not be saved.'); }
    return '/Tuman/uploads/profile-photos/' . $filename;
}

function tuman_save_profile(PDO $database, int $userId, string $role, array $input, array $upload): void
{
    $tables = ['ADMIN' => 'tmn_admin_profiles', 'TEACHER' => 'tmn_teacher_profiles', 'STUDENT' => 'tmn_student_profiles'];
    if (!isset($tables[$role])) { throw new InvalidArgumentException('Profile unavailable.'); }
    $values = tuman_profile_values($input); $photoPath = tuman_profile_photo($upload); $table = $tables[$role];
    $database->beginTransaction();
    try {
        $account = $database->prepare('UPDATE tmn_users SET email=:email WHERE id=:id AND role=:role');
        $account->execute(['email' => $values['email'] ?: null, 'id' => $userId, 'role' => $role]);
        $columns = 'user_id, first_name, last_name, phone, address_line1, address_line2, city, state_name, postal_code, profile_details, photo_path';
        $sql = "INSERT INTO {$table} ({$columns}) VALUES (:user_id,:first_name,:last_name,:phone,:address_line1,:address_line2,:city,:state_name,:postal_code,:profile_details,:photo_path) ON DUPLICATE KEY UPDATE first_name=VALUES(first_name),last_name=VALUES(last_name),phone=VALUES(phone),address_line1=VALUES(address_line1),address_line2=VALUES(address_line2),city=VALUES(city),state_name=VALUES(state_name),postal_code=VALUES(postal_code),profile_details=VALUES(profile_details),photo_path=COALESCE(VALUES(photo_path),photo_path)";
        $statement = $database->prepare($sql);
        // Email belongs to tmn_users and is not a placeholder in the profile statement.
        $profileValues = $values;
        unset($profileValues['email']);
        $statement->execute($profileValues + ['user_id' => $userId, 'photo_path' => $photoPath]);
        tuman_log_activity($database, $userId, 'PROFILE_UPDATED', 'USER', $userId);
        $database->commit();
    } catch (Throwable $exception) { if ($database->inTransaction()) { $database->rollBack(); } if ($exception instanceof PDOException && $exception->getCode() === '23000') { throw new InvalidArgumentException('That email address is already in use.'); } throw $exception; }
}
