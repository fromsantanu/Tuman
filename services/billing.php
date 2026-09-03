<?php
declare(strict_types=1);

require_once __DIR__ . '/teacher_students.php';
require_once dirname(__DIR__) . '/config/currencies.php';

const TUMAN_BILLING_MODES = ['FIXED_MONTHLY', 'HOURLY'];

function tuman_billing_valid_date(string $date): bool
{
    $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    return $parsed !== false && $parsed->format('Y-m-d') === $date;
}

function tuman_billing_normalize_rate(string $rate): ?string
{
    if (preg_match('/^\d{1,10}(?:\.\d{1,2})?$/', $rate) !== 1) { return null; }
    [$whole, $fraction] = array_pad(explode('.', $rate, 2), 2, '');
    $whole = ltrim($whole, '0');
    return ($whole === '' ? '0' : $whole) . '.' . str_pad($fraction, 2, '0');
}

/** @return array<string, string> */
function tuman_validate_billing(array $input): array
{
    $errors = [];
    if (trim((string)($input['rule_name'] ?? '')) === '' || strlen((string)($input['rule_name'] ?? '')) > 100) { $errors['rule_name'] = 'Rule name is required and must be 100 characters or fewer.'; }
    if (!in_array($input['billing_mode'] ?? '', TUMAN_BILLING_MODES, true)) { $errors['billing_mode'] = 'Choose a valid billing mode.'; }
    if (tuman_billing_normalize_rate($input['rate'] ?? '') === null) { $errors['rate'] = 'Rate must be a non-negative amount with no more than two decimal places.'; }
    if (tuman_currency_code((string) ($input['currency_code'] ?? 'INR')) === null) { $errors['currency_code'] = 'Choose a supported currency.'; }
    if (!tuman_billing_valid_date($input['effective_from'] ?? '')) { $errors['effective_from'] = 'Enter a valid effective-from date.'; }
    if (($input['effective_to'] ?? '') !== '' && !tuman_billing_valid_date($input['effective_to'])) { $errors['effective_to'] = 'Enter a valid effective-to date.'; }
    if (($input['effective_to'] ?? '') !== '' && tuman_billing_valid_date($input['effective_from'] ?? '') && $input['effective_to'] < $input['effective_from']) { $errors['effective_to'] = 'Effective-to date cannot be before the start date.'; }
    return $errors;
}

/** @return array{rule_name:string,billing_mode:string,rate:string,currency_code:string,effective_from:string,effective_to:?string} */
function tuman_billing_values(array $input): array
{
    $errors = tuman_validate_billing($input);
    if ($errors !== []) { throw new InvalidArgumentException(reset($errors)); }
    return ['rule_name' => trim((string)$input['rule_name']), 'billing_mode' => $input['billing_mode'], 'rate' => tuman_billing_normalize_rate($input['rate']), 'currency_code' => tuman_currency_code((string) ($input['currency_code'] ?? 'INR')), 'effective_from' => $input['effective_from'], 'effective_to' => $input['effective_to'] === '' ? null : $input['effective_to']];
}

/** @param array<string, mixed> $assignment */
function tuman_validate_billing_dates_for_assignment(array $assignment, string $effectiveFrom, ?string $effectiveTo): void
{
    if ($effectiveFrom < $assignment['start_date'] || ($assignment['end_date'] !== null && $effectiveFrom > $assignment['end_date']) || ($effectiveTo !== null && ($effectiveTo < $assignment['start_date'] || ($assignment['end_date'] !== null && $effectiveTo > $assignment['end_date'])))) { throw new InvalidArgumentException('Billing dates must fall within the student assignment dates.'); }
}

/** @return list<array<string, mixed>> */
function tuman_teacher_billing_rules(PDO $database, int $teacherId, ?int $assignmentId = null): array
{
    $sql = 'SELECT b.*, ts.status AS assignment_status, sp.first_name, sp.last_name FROM tmn_student_billing b INNER JOIN tmn_teacher_students ts ON ts.id = b.teacher_student_id INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id WHERE ts.teacher_user_id = :teacher_id';
    $params = ['teacher_id' => $teacherId];
    if ($assignmentId !== null) { $sql .= ' AND b.teacher_student_id = :assignment_id'; $params['assignment_id'] = $assignmentId; }
    $sql .= " ORDER BY b.status = 'ACTIVE' DESC, b.effective_from DESC, b.id DESC";
    $statement = $database->prepare($sql); $statement->execute($params); return $statement->fetchAll();
}

/** @return array<string, mixed>|null */
function tuman_teacher_billing_rule(PDO $database, int $teacherId, int $billingId): ?array
{
    $statement = $database->prepare('SELECT b.*, ts.teacher_user_id, ts.start_date AS assignment_start_date, ts.end_date AS assignment_end_date, ts.status AS assignment_status FROM tmn_student_billing b INNER JOIN tmn_teacher_students ts ON ts.id = b.teacher_student_id WHERE b.id = :id AND ts.teacher_user_id = :teacher_id');
    $statement->execute(['id' => $billingId, 'teacher_id' => $teacherId]); $record = $statement->fetch(); return is_array($record) ? $record : null;
}

/** @return list<array<string, mixed>> */
function tuman_lock_active_billing_rules(PDO $database, int $assignmentId): array
{
    $statement = $database->prepare("SELECT id, billing_mode, effective_from, effective_to FROM tmn_student_billing WHERE teacher_student_id = :assignment_id AND status = 'ACTIVE' FOR UPDATE");
    $statement->execute(['assignment_id' => $assignmentId]); return $statement->fetchAll();
}

/** @param list<array<string, mixed>> $rules */
function tuman_billing_has_overlap(array $rules, array $candidate, ?int $exceptId = null): bool
{
    $candidateEnd = $candidate['effective_to'] ?? '9999-12-31';
    foreach ($rules as $rule) {
        if (($exceptId !== null && (int) $rule['id'] === $exceptId) || $rule['billing_mode'] !== 'FIXED_MONTHLY' || $candidate['billing_mode'] !== 'FIXED_MONTHLY') { continue; }
        if ($candidate['effective_from'] <= ($rule['effective_to'] ?? '9999-12-31') && $rule['effective_from'] <= $candidateEnd) { return true; }
    }
    return false;
}

function tuman_billing_rate_label(string $rate, string $mode, string $currencyCode = 'INR'): string
{
    [$whole, $fraction] = explode('.', tuman_billing_normalize_rate($rate) ?? '0.00');
    $whole = preg_replace('/\B(?=(\d{3})+(?!\d))/', ',', $whole) ?? $whole;
    return tuman_currency_amount_label($whole . '.' . $fraction, $currencyCode) . ($mode === 'HOURLY' ? ' per hour' : ' per month');
}

function tuman_create_billing_rule(PDO $database, int $teacherId, int $assignmentId, array $input): void
{
    $ownsTransaction = !$database->inTransaction(); if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $assignment = tuman_teacher_student($database, $teacherId, $assignmentId);
        if ($assignment === null) { throw new InvalidArgumentException('Student not found.'); }
        if ($assignment['assignment_status'] !== 'ACTIVE') { throw new InvalidArgumentException('Choose an active student.'); }
        $values = tuman_billing_values($input); tuman_validate_billing_dates_for_assignment($assignment, $values['effective_from'], $values['effective_to']);
        if (tuman_billing_has_overlap(tuman_lock_active_billing_rules($database, $assignmentId), $values)) { throw new InvalidArgumentException('An active rule with this billing mode already covers part of that date range.'); }
        $statement = $database->prepare("INSERT INTO tmn_student_billing (teacher_student_id, rule_name, billing_mode, rate, currency_code, effective_from, effective_to, status) VALUES (:assignment_id, :rule_name, :billing_mode, :rate, :currency_code, :effective_from, :effective_to, 'ACTIVE')");
        $statement->execute(['assignment_id' => $assignmentId] + $values); $billingId = (int) $database->lastInsertId();
        tuman_log_activity($database, $teacherId, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', $billingId, ['billing_mode' => $values['billing_mode'], 'currency_code' => $values['currency_code']]);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } throw $exception; }
}

function tuman_update_billing_rule(PDO $database, int $teacherId, int $billingId, array $input): void
{
    $ownsTransaction = !$database->inTransaction(); if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $record = tuman_teacher_billing_rule($database, $teacherId, $billingId);
        if ($record === null) { throw new InvalidArgumentException('Billing rule not found.'); }
        $input['rule_name'] = $input['rule_name'] ?? $record['rule_name'];
        $values = tuman_billing_values($input); tuman_validate_billing_dates_for_assignment(['start_date' => $record['assignment_start_date'], 'end_date' => $record['assignment_end_date']], $values['effective_from'], $values['effective_to']);
        if ($record['status'] === 'ACTIVE' && tuman_billing_has_overlap(tuman_lock_active_billing_rules($database, (int) $record['teacher_student_id']), $values, $billingId)) { throw new InvalidArgumentException('An active rule with this billing mode already covers part of that date range.'); }
        $statement = $database->prepare('UPDATE tmn_student_billing SET rule_name = :rule_name, billing_mode = :billing_mode, rate = :rate, currency_code = :currency_code, effective_from = :effective_from, effective_to = :effective_to WHERE id = :id');
        $statement->execute($values + ['id' => $billingId]);
        tuman_log_activity($database, $teacherId, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', $billingId, ['billing_mode' => $values['billing_mode'], 'currency_code' => $values['currency_code']]);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } throw $exception; }
}

function tuman_deactivate_billing_rule(PDO $database, int $teacherId, int $billingId, string $effectiveTo): void
{
    $ownsTransaction = !$database->inTransaction(); if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $record = tuman_teacher_billing_rule($database, $teacherId, $billingId);
        if ($record === null || $record['status'] !== 'ACTIVE') { throw new InvalidArgumentException('Billing rule not found.'); }
        $endDate = $effectiveTo === '' ? $record['effective_to'] : $effectiveTo;
        if ($endDate !== null && (!tuman_billing_valid_date($endDate) || $endDate < $record['effective_from'])) { throw new InvalidArgumentException('Effective-to date cannot be before the start date.'); }
        tuman_validate_billing_dates_for_assignment(['start_date' => $record['assignment_start_date'], 'end_date' => $record['assignment_end_date']], $record['effective_from'], $endDate);
        $statement = $database->prepare("UPDATE tmn_student_billing SET status = 'INACTIVE', effective_to = :effective_to WHERE id = :id AND status = 'ACTIVE'");
        $statement->execute(['effective_to' => $endDate, 'id' => $billingId]); if ($statement->rowCount() !== 1) { throw new InvalidArgumentException('Billing rule not found.'); }
        tuman_log_activity($database, $teacherId, 'BILLING_RULE_STATUS_CHANGED', 'STUDENT_BILLING', $billingId, ['to' => 'INACTIVE']);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } throw $exception; }
}
