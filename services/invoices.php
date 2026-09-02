<?php
declare(strict_types=1);

require_once __DIR__ . '/billing.php';

const TUMAN_INVOICE_MAX_MINOR = 999999999999;

function tuman_invoice_month_dates(string $month): ?array
{
    if (preg_match('/^\d{4}-(0[1-9]|1[0-2])$/', $month) !== 1) { return null; }
    $from = new DateTimeImmutable($month . '-01');
    return ['from' => $from->format('Y-m-d'), 'to' => $from->modify('last day of this month')->format('Y-m-d')];
}

function tuman_invoice_valid_date(string $date): bool
{
    $parsed = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    return $parsed !== false && $parsed->format('Y-m-d') === $date;
}

function tuman_invoice_minor_from_decimal(string $amount): ?int
{
    $normalized = tuman_billing_normalize_rate($amount);
    if ($normalized === null) { return null; }
    [$whole, $fraction] = explode('.', $normalized);
    $minor = ((int) $whole * 100) + (int) $fraction;
    return $minor <= TUMAN_INVOICE_MAX_MINOR ? $minor : null;
}

function tuman_invoice_decimal_from_minor(int $minor): string
{
    return intdiv($minor, 100) . '.' . str_pad((string) ($minor % 100), 2, '0', STR_PAD_LEFT);
}

function tuman_invoice_decimal_from_hundredths(int $hundredths): string
{
    return intdiv($hundredths, 100) . '.' . str_pad((string) ($hundredths % 100), 2, '0', STR_PAD_LEFT);
}

function tuman_invoice_round_half_up(int $numerator, int $denominator): int
{
    return intdiv($numerator + intdiv($denominator, 2), $denominator);
}

function tuman_invoice_money_label(string $amount, string $currencyCode = 'INR'): string
{
    [$whole, $fraction] = explode('.', tuman_invoice_decimal_from_minor(tuman_invoice_minor_from_decimal($amount) ?? 0));
    return tuman_currency_amount_label($whole . '.' . $fraction, $currencyCode);
}

/** @return array<string, mixed>|null */
function tuman_teacher_invoice(PDO $database, int $teacherId, int $invoiceId): ?array
{
    $statement = $database->prepare('SELECT i.*, ts.teacher_user_id, ts.student_user_id, u.email, sp.first_name, sp.last_name, sp.address_line1, sp.address_line2, sp.city, sp.state_name, sp.postal_code, sp.country_code FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id = i.teacher_student_id INNER JOIN tmn_users u ON u.id = ts.student_user_id INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id WHERE i.id = :id AND ts.teacher_user_id = :teacher_id');
    $statement->execute(['id' => $invoiceId, 'teacher_id' => $teacherId]);
    $record = $statement->fetch(); return is_array($record) ? $record : null;
}

/** @return list<array<string, mixed>> */
function tuman_teacher_invoices(PDO $database, int $teacherId, ?int $assignmentId = null): array
{
    $sql = 'SELECT i.*, sp.first_name, sp.last_name FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id = i.teacher_student_id INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id WHERE ts.teacher_user_id = :teacher_id';
    $params = ['teacher_id' => $teacherId];
    if ($assignmentId !== null) { $sql .= ' AND i.teacher_student_id = :assignment_id'; $params['assignment_id'] = $assignmentId; }
    $sql .= ' ORDER BY i.billing_period_from DESC, i.id DESC';
    $statement = $database->prepare($sql); $statement->execute($params); return $statement->fetchAll();
}

/** @return list<array<string, mixed>> */
function tuman_teacher_invoice_items(PDO $database, int $teacherId, int $invoiceId): array
{
    if (tuman_teacher_invoice($database, $teacherId, $invoiceId) === null) { return []; }
    $statement = $database->prepare('SELECT ii.* FROM tmn_invoice_items ii INNER JOIN tmn_invoices i ON i.id = ii.invoice_id INNER JOIN tmn_teacher_students ts ON ts.id = i.teacher_student_id WHERE ii.invoice_id = :invoice_id AND ts.teacher_user_id = :teacher_id ORDER BY ii.sort_order, ii.id');
    $statement->execute(['invoice_id' => $invoiceId, 'teacher_id' => $teacherId]); return $statement->fetchAll();
}

/** @return list<array<string, mixed>> */
function tuman_invoice_rules_on_date(PDO $database, int $assignmentId, string $mode, string $date): array
{
    $statement = $database->prepare('SELECT id, billing_mode, rate, currency_code, effective_from, effective_to, status FROM tmn_student_billing WHERE teacher_student_id = :assignment_id AND billing_mode = :billing_mode AND effective_from <= :from_date AND (effective_to IS NULL OR effective_to >= :to_date) ORDER BY id');
    $statement->execute(['assignment_id' => $assignmentId, 'billing_mode' => $mode, 'from_date' => $date, 'to_date' => $date]); return $statement->fetchAll();
}

/** @return array<string, mixed> */
function tuman_invoice_required_rule(PDO $database, int $assignmentId, string $mode, string $date): array
{
    $rules = tuman_invoice_rules_on_date($database, $assignmentId, $mode, $date);
    if (count($rules) !== 1) { throw new InvalidArgumentException(count($rules) === 0 ? 'No applicable ' . strtolower(str_replace('_', ' ', $mode)) . ' billing rule exists for the invoice period.' : 'Billing rules are ambiguous for this invoice period.'); }
    return $rules[0];
}

/** @return list<array{description:string,quantity:string,unit_rate:string,amount:string,amount_minor:int,currency_code:string}> */
function tuman_invoice_generated_items(PDO $database, int $assignmentId, string $month, string $periodFrom, string $periodTo): array
{
    $items = [];
    $fixedRules = tuman_invoice_rules_on_date($database, $assignmentId, 'FIXED_MONTHLY', $periodFrom);
    if (count($fixedRules) > 1) { throw new InvalidArgumentException('Billing rules are ambiguous for this invoice period.'); }
    if ($fixedRules !== []) {
        $rateMinor = tuman_invoice_minor_from_decimal((string) $fixedRules[0]['rate']);
        if ($rateMinor === null) { throw new InvalidArgumentException('The billing rate is too large for an invoice.'); }
        $items[] = ['description' => 'Monthly tuition — ' . (new DateTimeImmutable($periodFrom))->format('F Y'), 'quantity' => '1.00', 'unit_rate' => tuman_invoice_decimal_from_minor($rateMinor), 'amount' => tuman_invoice_decimal_from_minor($rateMinor), 'amount_minor' => $rateMinor, 'currency_code' => (string) $fixedRules[0]['currency_code']];
    }
    $attendance = $database->prepare("SELECT session_date, start_time, end_time, duration_minutes FROM tmn_attendance WHERE teacher_student_id = :assignment_id AND status = 'PRESENT' AND duration_minutes > 0 AND session_date >= :period_from AND session_date <= :period_to ORDER BY session_date, start_time, id");
    $attendance->execute(['assignment_id' => $assignmentId, 'period_from' => $periodFrom, 'period_to' => $periodTo]);
    foreach ($attendance->fetchAll() as $session) {
        $rule = tuman_invoice_required_rule($database, $assignmentId, 'HOURLY', $session['session_date']);
        $rateMinor = tuman_invoice_minor_from_decimal((string) $rule['rate']);
        if ($rateMinor === null) { throw new InvalidArgumentException('The billing rate is too large for an invoice.'); }
        $quantityHundredths = tuman_invoice_round_half_up((int) $session['duration_minutes'] * 100, 60);
        $amountMinor = tuman_invoice_round_half_up($rateMinor * $quantityHundredths, 100);
        if ($amountMinor > TUMAN_INVOICE_MAX_MINOR) { throw new InvalidArgumentException('The generated invoice amount is too large.'); }
        $items[] = ['description' => 'Hourly tuition — ' . $session['session_date'] . ', ' . substr((string) $session['start_time'], 0, 5) . '–' . substr((string) $session['end_time'], 0, 5), 'quantity' => tuman_invoice_decimal_from_hundredths($quantityHundredths), 'unit_rate' => tuman_invoice_decimal_from_minor($rateMinor), 'amount' => tuman_invoice_decimal_from_minor($amountMinor), 'amount_minor' => $amountMinor, 'currency_code' => (string) $rule['currency_code']];
    }
    return $items;
}

function tuman_invoice_reserve_number(PDO $database, string $invoiceDate): string
{
    $database->prepare("INSERT IGNORE INTO tmn_invoice_sequences (sequence_scope, current_value) VALUES ('GLOBAL', 0)")->execute();
    $sequence = $database->query("SELECT current_value FROM tmn_invoice_sequences WHERE sequence_scope = 'GLOBAL' FOR UPDATE")->fetch();
    if (!is_array($sequence)) { throw new RuntimeException('Invoice sequence is unavailable.'); }
    $value = (int) $sequence['current_value'] + 1;
    $statement = $database->prepare("UPDATE tmn_invoice_sequences SET current_value = :value WHERE sequence_scope = 'GLOBAL'"); $statement->execute(['value' => $value]);
    return 'TMN-' . substr($invoiceDate, 0, 4) . '-' . str_pad((string) $value, 6, '0', STR_PAD_LEFT);
}

function tuman_create_invoice(PDO $database, int $teacherId, int $assignmentId, array $input): void
{
    $month = (string) ($input['billing_month'] ?? ''); $dates = tuman_invoice_month_dates($month);
    if ($dates === null) { throw new InvalidArgumentException('Choose a valid billing month.'); }
    $invoiceDate = (string) ($input['invoice_date'] ?? ''); $dueDate = (string) ($input['due_date'] ?? '');
    if (!tuman_invoice_valid_date($invoiceDate)) { throw new InvalidArgumentException('Enter a valid invoice date.'); }
    if ($dueDate !== '' && (!tuman_invoice_valid_date($dueDate) || $dueDate < $invoiceDate)) { throw new InvalidArgumentException('Due date cannot be before the invoice date.'); }
    $ownsTransaction = !$database->inTransaction(); if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $assignment = tuman_teacher_student($database, $teacherId, $assignmentId);
        if ($assignment === null) { throw new InvalidArgumentException('Student not found.'); }
        if ($assignment['assignment_status'] !== 'ACTIVE') { throw new InvalidArgumentException('Choose an active student.'); }
        if ($dates['from'] < $assignment['start_date'] || ($assignment['end_date'] !== null && $dates['to'] > $assignment['end_date'])) { throw new InvalidArgumentException('The billing month must fall within the student assignment dates.'); }
        $duplicate = $database->prepare("SELECT id FROM tmn_invoices WHERE teacher_student_id = :assignment_id AND billing_period_from = :period_from AND billing_period_to = :period_to AND status <> 'CANCELLED' FOR UPDATE");
        $duplicate->execute(['assignment_id' => $assignmentId, 'period_from' => $dates['from'], 'period_to' => $dates['to']]);
        if ($duplicate->fetch() !== false) { throw new InvalidArgumentException('A non-cancelled invoice already exists for this student and billing month.'); }
        $items = tuman_invoice_generated_items($database, $assignmentId, $month, $dates['from'], $dates['to']);
        if ($items === []) { throw new InvalidArgumentException('No billable attendance or billing rule exists for this month.'); }
        $currencies = array_values(array_unique(array_column($items, 'currency_code')));
        if (count($currencies) !== 1 || tuman_currency_code((string) $currencies[0]) === null) { throw new InvalidArgumentException('This month has billable items in different or unsupported currencies. Use consistent billing currencies before generating an invoice.'); }
        $currencyCode = $currencies[0];
        $subtotalMinor = array_sum(array_column($items, 'amount_minor'));
        if ($subtotalMinor > TUMAN_INVOICE_MAX_MINOR) { throw new InvalidArgumentException('The generated invoice total is too large.'); }
        $invoiceNumber = tuman_invoice_reserve_number($database, $invoiceDate);
        $header = $database->prepare("INSERT INTO tmn_invoices (invoice_number, teacher_student_id, billing_period_from, billing_period_to, invoice_date, due_date, subtotal, discount_amount, total_amount, currency_code, status) VALUES (:invoice_number, :assignment_id, :period_from, :period_to, :invoice_date, :due_date, :subtotal, '0.00', :total_amount, :currency_code, 'DRAFT')");
        $header->execute(['invoice_number' => $invoiceNumber, 'assignment_id' => $assignmentId, 'period_from' => $dates['from'], 'period_to' => $dates['to'], 'invoice_date' => $invoiceDate, 'due_date' => $dueDate === '' ? null : $dueDate, 'subtotal' => tuman_invoice_decimal_from_minor($subtotalMinor), 'total_amount' => tuman_invoice_decimal_from_minor($subtotalMinor), 'currency_code' => $currencyCode]);
        $invoiceId = (int) $database->lastInsertId(); $item = $database->prepare('INSERT INTO tmn_invoice_items (invoice_id, description, quantity, unit_rate, amount, sort_order) VALUES (:invoice_id, :description, :quantity, :unit_rate, :amount, :sort_order)');
        foreach ($items as $index => $values) { $item->execute(['invoice_id' => $invoiceId, 'description' => $values['description'], 'quantity' => $values['quantity'], 'unit_rate' => $values['unit_rate'], 'amount' => $values['amount'], 'sort_order' => $index + 1]); }
        tuman_log_activity($database, $teacherId, 'INVOICE_CREATED', 'INVOICE', $invoiceId, ['invoice_number' => $invoiceNumber, 'assignment_id' => $assignmentId, 'billing_month' => $month, 'currency_code' => $currencyCode, 'status' => 'DRAFT']);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } throw $exception; }
}

function tuman_change_invoice_status(PDO $database, int $teacherId, int $invoiceId, string $toStatus, string $action): void
{
    $ownsTransaction = !$database->inTransaction(); if ($ownsTransaction) { $database->beginTransaction(); }
    try {
        $invoice = tuman_teacher_invoice($database, $teacherId, $invoiceId);
        if ($invoice === null || $invoice['status'] !== 'DRAFT') { throw new InvalidArgumentException('Invoice unavailable.'); }
        $statement = $database->prepare("UPDATE tmn_invoices SET status = :status WHERE id = :id AND status = 'DRAFT'");
        $statement->execute(['status' => $toStatus, 'id' => $invoiceId]); if ($statement->rowCount() !== 1) { throw new InvalidArgumentException('Invoice unavailable.'); }
        tuman_log_activity($database, $teacherId, $action, 'INVOICE', $invoiceId, ['invoice_number' => $invoice['invoice_number'], 'to' => $toStatus]);
        if ($ownsTransaction) { $database->commit(); }
    } catch (Throwable $exception) { if ($ownsTransaction && $database->inTransaction()) { $database->rollBack(); } throw $exception; }
}

function tuman_issue_invoice(PDO $database, int $teacherId, int $invoiceId): void { tuman_change_invoice_status($database, $teacherId, $invoiceId, 'ISSUED', 'INVOICE_ISSUED'); }
function tuman_cancel_invoice(PDO $database, int $teacherId, int $invoiceId): void { tuman_change_invoice_status($database, $teacherId, $invoiceId, 'CANCELLED', 'INVOICE_CANCELLED'); }
