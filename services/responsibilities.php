<?php
declare(strict_types=1);

require_once __DIR__ . '/teacher_students.php';

const TUMAN_RESPONSIBILITY_FOR = ['TEACHER', 'STUDENT'];

function tuman_valid_date(string $date): bool
{
    $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    return $parsed !== false && $parsed->format('Y-m-d') === $date;
}

/** @return array<string, string> */
function tuman_validate_responsibility(array $input): array
{
    $errors = [];
    if (!in_array($input['responsibility_for'] ?? '', TUMAN_RESPONSIBILITY_FOR, true)) { $errors['responsibility_for'] = 'Choose Teacher or Student responsibility.'; }
    if (($input['title'] ?? '') === '' || strlen($input['title']) > 200) { $errors['title'] = 'Title is required and must be 200 characters or fewer.'; }
    if (strlen($input['details'] ?? '') > 65535) { $errors['details'] = 'Details are too long.'; }
    if (!tuman_valid_date($input['effective_from'] ?? '')) { $errors['effective_from'] = 'Enter a valid effective-from date.'; }
    if (($input['effective_to'] ?? '') !== '' && !tuman_valid_date($input['effective_to'])) { $errors['effective_to'] = 'Enter a valid effective-to date.'; }
    if (($input['effective_to'] ?? '') !== '' && tuman_valid_date($input['effective_from'] ?? '') && $input['effective_to'] < $input['effective_from']) { $errors['effective_to'] = 'Effective-to date cannot be before the start date.'; }
    return $errors;
}

/** @return list<array<string, mixed>> */
function tuman_teacher_responsibilities(PDO $database, int $teacherId, ?int $assignmentId = null): array
{
    $sql = 'SELECT r.id, r.teacher_student_id, r.responsibility_for, r.title, r.details, r.status, r.effective_from, r.effective_to, sp.first_name, sp.last_name
            FROM tmn_responsibilities r INNER JOIN tmn_teacher_students ts ON ts.id = r.teacher_student_id
            INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id
            WHERE ts.teacher_user_id = :teacher_id';
    $params = ['teacher_id' => $teacherId];
    if ($assignmentId !== null) { $sql .= ' AND r.teacher_student_id = :assignment_id'; $params['assignment_id'] = $assignmentId; }
    $sql .= ' ORDER BY r.status = \'ACTIVE\' DESC, r.effective_from DESC, r.id DESC';
    $statement = $database->prepare($sql); $statement->execute($params); return $statement->fetchAll();
}

/** @return array<string, mixed>|null */
function tuman_teacher_responsibility(PDO $database, int $teacherId, int $responsibilityId): ?array
{
    $statement = $database->prepare('SELECT r.* FROM tmn_responsibilities r INNER JOIN tmn_teacher_students ts ON ts.id = r.teacher_student_id WHERE r.id = :id AND ts.teacher_user_id = :teacher_id');
    $statement->execute(['id' => $responsibilityId, 'teacher_id' => $teacherId]); $record = $statement->fetch(); return is_array($record) ? $record : null;
}

function tuman_create_responsibility(PDO $database, int $teacherId, int $assignmentId, array $input): void
{
    if (tuman_teacher_student($database, $teacherId, $assignmentId) === null) { throw new InvalidArgumentException('Student not found.'); }
    $assignment = $database->prepare("SELECT id FROM tmn_teacher_students WHERE id = :id AND teacher_user_id = :teacher_id AND status = 'ACTIVE'");
    $assignment->execute(['id' => $assignmentId, 'teacher_id' => $teacherId]); if ($assignment->fetch() === false) { throw new InvalidArgumentException('Choose an active student.'); }
    $errors = tuman_validate_responsibility($input); if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    $statement = $database->prepare("INSERT INTO tmn_responsibilities (teacher_student_id, responsibility_for, title, details, status, effective_from, effective_to) VALUES (:assignment_id, :responsibility_for, :title, :details, 'ACTIVE', :effective_from, :effective_to)");
    $statement->execute(['assignment_id' => $assignmentId, 'responsibility_for' => $input['responsibility_for'], 'title' => $input['title'], 'details' => $input['details'] === '' ? null : $input['details'], 'effective_from' => $input['effective_from'], 'effective_to' => $input['effective_to'] === '' ? null : $input['effective_to']]);
    $responsibilityId = (int) $database->lastInsertId();
    tuman_log_activity($database, $teacherId, 'RESPONSIBILITY_CREATED', 'RESPONSIBILITY', $responsibilityId, ['assignment_id' => $assignmentId, 'responsibility_for' => $input['responsibility_for']]);
}

function tuman_update_responsibility(PDO $database, int $teacherId, int $responsibilityId, array $input): void
{
    if (tuman_teacher_responsibility($database, $teacherId, $responsibilityId) === null) { throw new InvalidArgumentException('Responsibility not found.'); }
    $errors = tuman_validate_responsibility($input); if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    $statement = $database->prepare('UPDATE tmn_responsibilities SET responsibility_for = :responsibility_for, title = :title, details = :details, effective_from = :effective_from, effective_to = :effective_to WHERE id = :id');
    $statement->execute(['responsibility_for' => $input['responsibility_for'], 'title' => $input['title'], 'details' => $input['details'] === '' ? null : $input['details'], 'effective_from' => $input['effective_from'], 'effective_to' => $input['effective_to'] === '' ? null : $input['effective_to'], 'id' => $responsibilityId]);
    tuman_log_activity($database, $teacherId, 'RESPONSIBILITY_UPDATED', 'RESPONSIBILITY', $responsibilityId);
}

function tuman_deactivate_responsibility(PDO $database, int $teacherId, int $responsibilityId): void
{
    $record = tuman_teacher_responsibility($database, $teacherId, $responsibilityId);
    if ($record === null || $record['status'] !== 'ACTIVE') { throw new InvalidArgumentException('Responsibility not found.'); }
    $statement = $database->prepare("UPDATE tmn_responsibilities SET status = 'INACTIVE' WHERE id = :id AND status = 'ACTIVE'"); $statement->execute(['id' => $responsibilityId]);
    if ($statement->rowCount() !== 1) { throw new InvalidArgumentException('Responsibility not found.'); }
    tuman_log_activity($database, $teacherId, 'RESPONSIBILITY_STATUS_CHANGED', 'RESPONSIBILITY', $responsibilityId, ['to' => 'INACTIVE']);
}
