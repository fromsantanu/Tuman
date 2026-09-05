<?php
declare(strict_types=1);

require_once __DIR__ . '/batches.php';

const TUMAN_ATTENDANCE_STATUSES = ['PRESENT', 'ABSENT', 'LEAVE', 'CANCELLED', 'HOLIDAY'];

function tuman_attendance_valid_date(string $date): bool
{
    $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    return $parsed !== false && $parsed->format('Y-m-d') === $date;
}

function tuman_attendance_valid_time(string $time): bool
{
    return preg_match('/^(?:[01]\\d|2[0-3]):[0-5]\\d(?::[0-5]\\d)?$/', $time) === 1;
}

function tuman_attendance_seconds(string $time): int
{
    $parts = array_map('intval', explode(':', $time));
    return ($parts[0] * 3600) + ($parts[1] * 60) + ($parts[2] ?? 0);
}

/** @return array<string, string> */
function tuman_validate_attendance(array $input): array
{
    $errors = [];
    $status = $input['status'] ?? '';
    if (!in_array($status, TUMAN_ATTENDANCE_STATUSES, true)) { $errors['status'] = 'Choose a valid attendance status.'; }
    if (!tuman_attendance_valid_date($input['session_date'] ?? '')) { $errors['session_date'] = 'Enter a valid session date.'; }
    if (strlen($input['remarks'] ?? '') > 500) { $errors['remarks'] = 'Remarks must be 500 characters or fewer.'; }
    if ($status === 'PRESENT') {
        if (!tuman_attendance_valid_time($input['start_time'] ?? '')) { $errors['start_time'] = 'Enter a valid start time.'; }
        if (!tuman_attendance_valid_time($input['end_time'] ?? '')) { $errors['end_time'] = 'Enter a valid end time.'; }
        if (!isset($errors['start_time'], $errors['end_time']) && tuman_attendance_seconds($input['end_time']) <= tuman_attendance_seconds($input['start_time'])) { $errors['end_time'] = 'End time must be later than start time.'; }
    }
    return $errors;
}

/** @return array{session_date:string,status:string,start_time:?string,end_time:?string,duration_minutes:?int,remarks:?string} */
function tuman_attendance_values(array $input): array
{
    $errors = tuman_validate_attendance($input);
    if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    $status = $input['status'];
    if ($status !== 'PRESENT') { return ['session_date' => $input['session_date'], 'status' => $status, 'start_time' => null, 'end_time' => null, 'duration_minutes' => null, 'remarks' => $input['remarks'] === '' ? null : $input['remarks']]; }
    $start = strlen($input['start_time']) === 5 ? $input['start_time'] . ':00' : $input['start_time'];
    $end = strlen($input['end_time']) === 5 ? $input['end_time'] . ':00' : $input['end_time'];
    return ['session_date' => $input['session_date'], 'status' => $status, 'start_time' => $start, 'end_time' => $end, 'duration_minutes' => intdiv(tuman_attendance_seconds($end) - tuman_attendance_seconds($start), 60), 'remarks' => $input['remarks'] === '' ? null : $input['remarks']];
}

/** @return list<array<string, mixed>> */
function tuman_teacher_attendance_list(PDO $database, int $teacherId, ?int $assignmentId = null, ?string $month = null): array
{
    $sql = 'SELECT a.*, b.rule_name AS billing_rule_name, bt.batch_name, ts.status AS assignment_status, sp.first_name, sp.last_name FROM tmn_attendance a INNER JOIN tmn_teacher_students ts ON ts.id = a.teacher_student_id INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id LEFT JOIN tmn_student_billing b ON b.id=a.billing_rule_id LEFT JOIN tmn_batches bt ON bt.id=a.batch_id WHERE ts.teacher_user_id = :teacher_id';
    $params = ['teacher_id' => $teacherId];
    if ($assignmentId !== null) { $sql .= ' AND a.teacher_student_id = :assignment_id'; $params['assignment_id'] = $assignmentId; }
    if ($month !== null) { $sql .= ' AND a.session_date >= :month_start AND a.session_date < :month_end'; $params['month_start'] = $month . '-01'; $params['month_end'] = (new DateTimeImmutable($month . '-01'))->modify('+1 month')->format('Y-m-d'); }
    $sql .= ' ORDER BY a.session_date DESC, a.start_time DESC, a.id DESC';
    $statement = $database->prepare($sql); $statement->execute($params); return $statement->fetchAll();
}

/** @return array<string, mixed>|null */
function tuman_teacher_attendance(PDO $database, int $teacherId, int $attendanceId): ?array
{
    $statement = $database->prepare('SELECT a.*, ts.teacher_user_id, ts.start_date AS assignment_start_date, ts.end_date AS assignment_end_date, ts.status AS assignment_status FROM tmn_attendance a INNER JOIN tmn_teacher_students ts ON ts.id = a.teacher_student_id WHERE a.id = :id AND ts.teacher_user_id = :teacher_id');
    $statement->execute(['id' => $attendanceId, 'teacher_id' => $teacherId]);
    $record = $statement->fetch(); return is_array($record) ? $record : null;
}

/** @param array<string, mixed> $assignment */
function tuman_validate_attendance_assignment_date(array $assignment, string $sessionDate): void
{
    if ($sessionDate < $assignment['start_date'] || ($assignment['end_date'] !== null && $sessionDate > $assignment['end_date'])) { throw new InvalidArgumentException('Session date must fall within the student assignment dates.'); }
}

function tuman_attendance_duplicate_exists(PDO $database, int $assignmentId, array $values, ?int $exceptId = null): bool
{
    if ($values['start_time'] === null) { return false; }
    $sql = 'SELECT id FROM tmn_attendance WHERE teacher_student_id = :assignment_id AND session_date = :session_date AND start_time = :start_time';
    $params = ['assignment_id' => $assignmentId, 'session_date' => $values['session_date'], 'start_time' => $values['start_time']];
    if ($exceptId !== null) { $sql .= ' AND id <> :except_id'; $params['except_id'] = $exceptId; }
    $statement = $database->prepare($sql); $statement->execute($params); return $statement->fetch() !== false;
}

function tuman_attendance_billing_rule_id(PDO $database,int $teacherId,int $assignmentId,array $values,array $input): ?int
{
    if ($values['status'] !== 'PRESENT' || ($input['billing_rule_id'] ?? '') === '') { return null; }
    $id=filter_var($input['billing_rule_id'],FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);if(!$id){throw new InvalidArgumentException('Choose a valid hourly rule.');}
    $rule=tuman_teacher_billing_rule($database,$teacherId,(int)$id);
    if($rule===null||$rule['teacher_student_id']!=$assignmentId||$rule['billing_mode']!=='HOURLY'||$rule['status']!=='ACTIVE'||$rule['effective_from']>$values['session_date']||($rule['effective_to']!==null&&$rule['effective_to']<$values['session_date'])){throw new InvalidArgumentException('The selected hourly rule is not applicable to this session.');}
    return (int)$id;
}

function tuman_create_attendance(PDO $database, int $teacherId, int $assignmentId, array $input): void
{
    $assignment = tuman_teacher_student($database, $teacherId, $assignmentId);
    if ($assignment === null) { throw new InvalidArgumentException('Student not found.'); }
    if ($assignment['assignment_status'] !== 'ACTIVE') { throw new InvalidArgumentException('Choose an active student.'); }
    $values = tuman_attendance_values($input); tuman_validate_attendance_assignment_date($assignment, $values['session_date']); $values['billing_rule_id']=tuman_attendance_billing_rule_id($database,$teacherId,$assignmentId,$values,$input); $values['batch_id']=tuman_batch_attendance_id($database,$teacherId,$assignmentId,$values,$input); $values['batch_billing_rule_id']=null;
    if (tuman_attendance_duplicate_exists($database, $assignmentId, $values)) { throw new InvalidArgumentException('A session with this date and start time already exists.'); }
    try {
        $statement = $database->prepare('INSERT INTO tmn_attendance (teacher_student_id, billing_rule_id, batch_id, batch_billing_rule_id, session_date, start_time, end_time, duration_minutes, status, remarks) VALUES (:assignment_id, :billing_rule_id, :batch_id, :batch_billing_rule_id, :session_date, :start_time, :end_time, :duration_minutes, :status, :remarks)');
        $statement->execute(['assignment_id' => $assignmentId] + $values); $attendanceId = (int) $database->lastInsertId();
        tuman_log_activity($database, $teacherId, 'ATTENDANCE_CREATED', 'ATTENDANCE', $attendanceId, ['assignment_id' => $assignmentId, 'status' => $values['status']]);
    } catch (PDOException $exception) { if ($exception->getCode() === '23000') { throw new InvalidArgumentException('A session with this date and start time already exists.'); } throw $exception; }
}

function tuman_update_attendance(PDO $database, int $teacherId, int $attendanceId, array $input): void
{
    $record = tuman_teacher_attendance($database, $teacherId, $attendanceId);
    if ($record === null) { throw new InvalidArgumentException('Attendance record not found.'); }
    $values = tuman_attendance_values($input); tuman_validate_attendance_assignment_date(['start_date' => $record['assignment_start_date'], 'end_date' => $record['assignment_end_date']], $values['session_date']); $values['billing_rule_id']=array_key_exists('billing_rule_id',$input)?tuman_attendance_billing_rule_id($database,$teacherId,(int)$record['teacher_student_id'],$values,$input):$record['billing_rule_id']; $values['batch_id']=array_key_exists('batch_id',$input)?tuman_batch_attendance_id($database,$teacherId,(int)$record['teacher_student_id'],$values,$input):$record['batch_id']; $values['batch_billing_rule_id']=null;
    if (tuman_attendance_duplicate_exists($database, (int) $record['teacher_student_id'], $values, $attendanceId)) { throw new InvalidArgumentException('A session with this date and start time already exists.'); }
    try {
        $statement = $database->prepare('UPDATE tmn_attendance SET billing_rule_id = :billing_rule_id, batch_id = :batch_id, batch_billing_rule_id = :batch_billing_rule_id, session_date = :session_date, start_time = :start_time, end_time = :end_time, duration_minutes = :duration_minutes, status = :status, remarks = :remarks WHERE id = :id');
        $statement->execute($values + ['id' => $attendanceId]);
        tuman_log_activity($database, $teacherId, 'ATTENDANCE_UPDATED', 'ATTENDANCE', $attendanceId, ['status' => $values['status']]);
    } catch (PDOException $exception) { if ($exception->getCode() === '23000') { throw new InvalidArgumentException('A session with this date and start time already exists.'); } throw $exception; }
}

function tuman_cancel_attendance(PDO $database, int $teacherId, int $attendanceId): void
{
    $record = tuman_teacher_attendance($database, $teacherId, $attendanceId);
    if ($record === null || $record['status'] === 'CANCELLED') { throw new InvalidArgumentException('Attendance record not found.'); }
    $statement = $database->prepare("UPDATE tmn_attendance SET status = 'CANCELLED', start_time = NULL, end_time = NULL, duration_minutes = NULL WHERE id = :id");
    $statement->execute(['id' => $attendanceId]);
    tuman_log_activity($database, $teacherId, 'ATTENDANCE_STATUS_CHANGED', 'ATTENDANCE', $attendanceId, ['to' => 'CANCELLED']);
}
