<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once __DIR__ . '/activity_log.php';
require_once dirname(__DIR__) . '/config/currencies.php';

/** @return array<string, string> */
function tuman_validate_student_input(array $input): array
{
    $errors = [];
    if (($input['username'] ?? '') === '' || strlen($input['username']) > 50) { $errors['username'] = 'Username is required and must be 50 characters or fewer.'; }
    if (($input['first_name'] ?? '') === '' || strlen($input['first_name']) > 100) { $errors['first_name'] = 'First name is required and must be 100 characters or fewer.'; }
    if (strlen($input['last_name'] ?? '') > 100) { $errors['last_name'] = 'Last name must be 100 characters or fewer.'; }
    if (($input['email'] ?? '') !== '' && (strlen($input['email']) > 254 || filter_var($input['email'], FILTER_VALIDATE_EMAIL) === false)) { $errors['email'] = 'Enter a valid email address or leave it blank.'; }
    if (($input['country_code'] ?? '') !== '' && tuman_country_code((string) $input['country_code']) === null) { $errors['country_code'] = 'Choose a supported country or leave it blank.'; }
    return $errors;
}

/** @return list<array<string, mixed>> */
function tuman_teacher_students(PDO $database, int $teacherId): array
{
    $statement = $database->prepare(
        'SELECT ts.id AS assignment_id, ts.start_date, ts.end_date, ts.status AS assignment_status,
                u.id AS student_user_id, u.username, u.email, sp.first_name, sp.last_name, sp.phone, sp.country_code
         FROM tmn_teacher_students ts
         INNER JOIN tmn_users u ON u.id = ts.student_user_id AND u.role = \'STUDENT\'
         INNER JOIN tmn_student_profiles sp ON sp.user_id = u.id
         WHERE ts.teacher_user_id = :teacher_id
         ORDER BY ts.status = \'ACTIVE\' DESC, sp.first_name, sp.last_name'
    );
    $statement->execute(['teacher_id' => $teacherId]);
    return $statement->fetchAll();
}

/** @return array<string, mixed>|null */
function tuman_teacher_student(PDO $database, int $teacherId, int $assignmentId): ?array
{
    $statement = $database->prepare(
        'SELECT ts.id AS assignment_id, ts.teacher_user_id, ts.student_user_id, ts.start_date, ts.end_date, ts.status AS assignment_status,
                u.username, u.email, u.status AS account_status, sp.first_name, sp.last_name, sp.phone,
                sp.address_line1, sp.address_line2, sp.city, sp.state_name, sp.postal_code, sp.country_code, sp.guardian_name, sp.guardian_phone, sp.profile_details, sp.photo_path
         FROM tmn_teacher_students ts
         INNER JOIN tmn_users u ON u.id = ts.student_user_id AND u.role = \'STUDENT\'
         INNER JOIN tmn_student_profiles sp ON sp.user_id = u.id
         WHERE ts.id = :assignment_id AND ts.teacher_user_id = :teacher_id'
    );
    $statement->execute(['assignment_id' => $assignmentId, 'teacher_id' => $teacherId]);
    $student = $statement->fetch();
    return is_array($student) ? $student : null;
}

/** Returns the contact profile shown to a Teacher before creating their own assignment. */
function tuman_existing_student_profile_for_link(PDO $database, string $email): ?array
{
    $statement = $database->prepare("SELECT u.id AS student_user_id, u.username, u.email, sp.first_name, sp.last_name, sp.phone, sp.address_line1, sp.address_line2, sp.city, sp.state_name, sp.postal_code, sp.country_code, sp.guardian_name, sp.guardian_phone, sp.profile_details, sp.photo_path FROM tmn_users u INNER JOIN tmn_student_profiles sp ON sp.user_id=u.id WHERE u.email=:email AND u.role='STUDENT' AND u.status='ACTIVE'");
    $statement->execute(['email' => trim($email)]);
    $row = $statement->fetch();
    return is_array($row) ? $row : null;
}

function tuman_enrol_student(PDO $database, int $teacherId, array $input): int
{
    $errors = tuman_validate_student_input($input);
    if (strlen($input['password'] ?? '') < 12) { $errors['password'] = 'Password must be at least 12 characters long.'; }
    if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    $ownsTransaction = !$database->inTransaction();
    if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $user = $database->prepare("INSERT INTO tmn_users (username, password_hash, email, role, status) VALUES (:username, :password_hash, :email, 'STUDENT', 'ACTIVE')");
        $user->execute(['username' => $input['username'], 'password_hash' => password_hash($input['password'], PASSWORD_DEFAULT), 'email' => $input['email'] === '' ? null : $input['email']]);
        $studentId = (int) $database->lastInsertId();
        $profile = $database->prepare('INSERT INTO tmn_student_profiles (user_id, first_name, last_name, phone, address_line1, address_line2, city, state_name, postal_code, country_code, guardian_name, guardian_phone) VALUES (:user_id, :first_name, :last_name, :phone, :address_line1, :address_line2, :city, :state_name, :postal_code, :country_code, :guardian_name, :guardian_phone)');
        $profile->execute(['user_id' => $studentId, 'first_name' => $input['first_name'], 'last_name' => $input['last_name'] ?: null, 'phone' => $input['phone'] ?: null, 'address_line1' => $input['address_line1'] ?: null, 'address_line2' => $input['address_line2'] ?: null, 'city' => $input['city'] ?: null, 'state_name' => $input['state_name'] ?: null, 'postal_code' => $input['postal_code'] ?: null, 'country_code' => tuman_country_code((string) ($input['country_code'] ?? '')), 'guardian_name' => $input['guardian_name'] ?: null, 'guardian_phone' => $input['guardian_phone'] ?: null]);
        $assignment = $database->prepare("INSERT INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status) VALUES (:teacher_id, :student_id, UTC_DATE(), 'ACTIVE')");
        $assignment->execute(['teacher_id' => $teacherId, 'student_id' => $studentId]);
        $assignmentId = (int) $database->lastInsertId();
        tuman_log_activity($database, $teacherId, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', $assignmentId, ['student_id' => $studentId]);
        if ($ownsTransaction) { $database->commit(); }
        return $assignmentId;
    } catch (Throwable $exception) {
        if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); }
        if ($exception instanceof PDOException && $exception->getCode() === '23000') { throw new InvalidArgumentException('That username or email address is already in use.'); }
        throw $exception;
    }
}

function tuman_link_existing_student(PDO $database, int $teacherId, string $email): void
{
    $email = trim($email);
    if ($email === '' || filter_var($email, FILTER_VALIDATE_EMAIL) === false) { throw new InvalidArgumentException('Enter a valid student email address.'); }
    $database->beginTransaction();
    try {
        $statement = $database->prepare("SELECT id FROM tmn_users WHERE email = :email AND role = 'STUDENT' AND status = 'ACTIVE' FOR UPDATE");
        $statement->execute(['email' => $email]); $studentId = $statement->fetchColumn();
        if ($studentId === false) { throw new InvalidArgumentException('This student account cannot be linked.'); }
        $existing = $database->prepare('SELECT id FROM tmn_teacher_students WHERE teacher_user_id = :teacher_id AND student_user_id = :student_id FOR UPDATE');
        $existing->execute(['teacher_id' => $teacherId, 'student_id' => $studentId]);
        if ($existing->fetchColumn() !== false) { throw new InvalidArgumentException('This student account cannot be linked.'); }
        $assignment = $database->prepare("INSERT INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status) VALUES (:teacher_id, :student_id, UTC_DATE(), 'ACTIVE')");
        $assignment->execute(['teacher_id' => $teacherId, 'student_id' => $studentId]); $assignmentId=(int)$database->lastInsertId();
        tuman_log_activity($database, $teacherId, 'STUDENT_LINKED', 'TEACHER_STUDENT', $assignmentId, ['student_id' => (int)$studentId]);
        $database->commit();
    } catch (Throwable $exception) { if ($database->inTransaction()) { $database->rollBack(); } if ($exception instanceof PDOException && $exception->getCode() === '23000') { throw new InvalidArgumentException('This student account cannot be linked.'); } throw $exception; }
}

function tuman_update_teacher_student(PDO $database, int $teacherId, int $assignmentId, array $input): void
{
    $student = tuman_teacher_student($database, $teacherId, $assignmentId);
    if ($student === null) { throw new InvalidArgumentException('Student not found.'); }
    $input['username'] = $student['username'];
    $errors = tuman_validate_student_input($input);
    unset($errors['username']);
    if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    try {
        $ownsTransaction = !$database->inTransaction();
        if ($ownsTransaction) { $database->beginTransaction(); }
        $account = $database->prepare('UPDATE tmn_users SET email = :email WHERE id = :id');
        $account->execute(['email' => $input['email'] === '' ? null : $input['email'], 'id' => $student['student_user_id']]);
        $countryCode = tuman_country_code((string) ($input['country_code'] ?? ''));
        $profile = $database->prepare('UPDATE tmn_student_profiles SET first_name = :first_name, last_name = :last_name, phone = :phone, address_line1 = :address_line1, address_line2 = :address_line2, city = :city, state_name = :state_name, postal_code = :postal_code, country_code = :country_code, guardian_name = :guardian_name, guardian_phone = :guardian_phone, profile_details = :profile_details WHERE user_id = :user_id');
        $profile->execute(['first_name' => $input['first_name'], 'last_name' => $input['last_name'] ?: null, 'phone' => $input['phone'] ?: null, 'address_line1' => $input['address_line1'] ?: null, 'address_line2' => $input['address_line2'] ?: null, 'city' => $input['city'] ?: null, 'state_name' => $input['state_name'] ?: null, 'postal_code' => $input['postal_code'] ?: null, 'country_code' => $countryCode, 'guardian_name' => $input['guardian_name'] ?: null, 'guardian_phone' => $input['guardian_phone'] ?: null, 'profile_details' => ($input['profile_details'] ?? '') ?: null, 'user_id' => $student['student_user_id']]);
        tuman_log_activity($database, $teacherId, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', $assignmentId, ['country_changed' => $countryCode !== ($student['country_code'] ?? null)]);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } if ($exception instanceof PDOException && $exception->getCode() === '23000') { throw new InvalidArgumentException('That email address is already in use.'); } throw $exception; }
}

function tuman_deactivate_teacher_student(PDO $database, int $teacherId, int $assignmentId): void
{
    $student = tuman_teacher_student($database, $teacherId, $assignmentId);
    if ($student === null || $student['assignment_status'] !== 'ACTIVE') { throw new InvalidArgumentException('Student not found.'); }
    $statement = $database->prepare("UPDATE tmn_teacher_students SET status = 'INACTIVE', end_date = UTC_DATE() WHERE id = :id AND teacher_user_id = :teacher_id AND status = 'ACTIVE'");
    $statement->execute(['id' => $assignmentId, 'teacher_id' => $teacherId]);
    if ($statement->rowCount() !== 1) { throw new InvalidArgumentException('Student not found.'); }
    tuman_log_activity($database, $teacherId, 'TEACHER_STUDENT_STATUS_CHANGED', 'TEACHER_STUDENT', $assignmentId, ['to' => 'INACTIVE']);
}
