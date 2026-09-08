<?php
declare(strict_types=1);
require_once __DIR__ . '/invoices.php';
require_once __DIR__ . '/activity_log.php';

const TUMAN_PAYMENT_METHODS = ['CASH', 'UPI', 'BANK_TRANSFER', 'CARD', 'OTHER'];

function tuman_payment_values(array $input): array
{
    $date = trim((string) ($input['payment_date'] ?? ''));
    $amount = tuman_billing_normalize_rate(trim((string) ($input['amount'] ?? '')));
    $method = trim((string) ($input['payment_method'] ?? ''));
    $reference = trim((string) ($input['reference_number'] ?? ''));
    $remarks = trim((string) ($input['remarks'] ?? ''));
    if (!tuman_invoice_valid_date($date)) { throw new InvalidArgumentException('Enter a valid payment date.'); }
    if ($amount === null || tuman_invoice_minor_from_decimal($amount) === null || tuman_invoice_minor_from_decimal($amount) <= 0) { throw new InvalidArgumentException('Amount must be greater than zero with no more than two decimal places.'); }
    if (!in_array($method, TUMAN_PAYMENT_METHODS, true)) { throw new InvalidArgumentException('Choose a valid payment method.'); }
    if (strlen($reference) > 100 || strlen($remarks) > 500) { throw new InvalidArgumentException('Reference or remarks are too long.'); }
    return ['payment_date' => $date, 'amount' => $amount, 'amount_minor' => tuman_invoice_minor_from_decimal($amount), 'payment_method' => $method, 'reference_number' => $reference === '' ? null : $reference, 'remarks' => $remarks === '' ? null : $remarks];
}

function tuman_teacher_payment(PDO $database, int $teacherId, int $paymentId): ?array
{
    $statement = $database->prepare('SELECT p.*, i.invoice_number, i.total_amount, i.currency_code, i.status AS invoice_status, sp.first_name, sp.last_name FROM tmn_payments p INNER JOIN tmn_invoices i ON i.id = p.invoice_id INNER JOIN tmn_teacher_students ts ON ts.id = i.teacher_student_id INNER JOIN tmn_student_profiles sp ON sp.user_id = ts.student_user_id WHERE p.id = :id AND ts.teacher_user_id = :teacher_id');
    $statement->execute(['id' => $paymentId, 'teacher_id' => $teacherId]); $row = $statement->fetch(); return is_array($row) ? $row : null;
}

function tuman_teacher_payment_invoices(PDO $database, int $teacherId, bool $eligibleOnly = false): array
{
    $sql = "SELECT i.*, sp.first_name, sp.last_name, GREATEST(0, i.total_amount - COALESCE((SELECT SUM(p.amount) FROM tmn_payments p WHERE p.invoice_id=i.id AND p.status='VALID'),0) + COALESCE((SELECT SUM(r.amount) FROM tmn_refunds r WHERE r.invoice_id=i.id AND r.refund_type='PAYMENT'),0) - COALESCE((SELECT SUM(ca.amount) FROM tmn_credit_applications ca WHERE ca.invoice_id=i.id),0)) AS outstanding_amount FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id INNER JOIN tmn_student_profiles sp ON sp.user_id=ts.student_user_id WHERE ts.teacher_user_id=:teacher_id";
    if ($eligibleOnly) { $sql .= " AND i.status IN ('ISSUED','PARTIALLY_PAID')"; }
    $sql .= ' ORDER BY i.invoice_date DESC, i.id DESC'; $statement = $database->prepare($sql); $statement->execute(['teacher_id' => $teacherId]); return $statement->fetchAll();
}

function tuman_invoice_valid_payment_minor(PDO $database, int $invoiceId, string $currencyCode): int
{
    $statement = $database->prepare("SELECT amount, currency_code FROM tmn_payments WHERE invoice_id=:invoice_id AND status='VALID' FOR UPDATE"); $statement->execute(['invoice_id' => $invoiceId]); $total = 0;
    foreach ($statement->fetchAll() as $payment) { if (($payment['currency_code'] ?? '') !== $currencyCode) { throw new RuntimeException('Stored payment currency is inconsistent with its invoice.'); } $minor = tuman_invoice_minor_from_decimal((string) $payment['amount']); if ($minor === null) { throw new RuntimeException('Stored payment amount is invalid.'); } $total += $minor; }
    return $total;
}

function tuman_locked_teacher_invoice(PDO $database, int $teacherId, int $invoiceId): ?array
{
    $statement = $database->prepare('SELECT i.*, ts.teacher_user_id FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id WHERE i.id=:id AND ts.teacher_user_id=:teacher_id FOR UPDATE'); $statement->execute(['id' => $invoiceId, 'teacher_id' => $teacherId]); $row=$statement->fetch(); return is_array($row)?$row:null;
}

function tuman_update_invoice_payment_status(PDO $database, int $teacherId, array $invoice, int $validMinor): string
{
    $totalMinor = tuman_invoice_minor_from_decimal((string) $invoice['total_amount']); if ($totalMinor === null) { throw new RuntimeException('Invoice payment total is invalid.'); }
    // Always calculate from the stored financial ledger. This includes credits
    // applied by the Teacher and avoids relying on a stale caller-provided total.
    $payments = $database->prepare("SELECT COALESCE(SUM(amount),0) FROM tmn_payments WHERE invoice_id=:invoice_id AND status='VALID'");
    $payments->execute(['invoice_id' => $invoice['id']]);
    $credits = $database->prepare('SELECT COALESCE(SUM(amount),0) FROM tmn_credit_applications WHERE invoice_id=:invoice_id');
    $credits->execute(['invoice_id' => $invoice['id']]);
    $refunds = $database->prepare("SELECT COALESCE(SUM(amount),0) FROM tmn_refunds WHERE invoice_id=:invoice_id AND refund_type='PAYMENT'");
    $refunds->execute(['invoice_id' => $invoice['id']]);
    $paymentMinor = (tuman_invoice_minor_from_decimal((string) $payments->fetchColumn()) ?? 0) - (tuman_invoice_minor_from_decimal((string) $refunds->fetchColumn()) ?? 0);
    $creditMinor = tuman_invoice_minor_from_decimal((string) $credits->fetchColumn()) ?? 0;
    $settledMinor = min($paymentMinor + $creditMinor, $totalMinor);
    $status = $settledMinor === 0 ? 'ISSUED' : ($settledMinor === $totalMinor ? 'PAID' : 'PARTIALLY_PAID');
    $statement=$database->prepare('UPDATE tmn_invoices SET status=:status WHERE id=:id');$statement->execute(['status'=>$status,'id'=>$invoice['id']]);
    tuman_log_activity($database,$teacherId,'INVOICE_PAYMENT_STATUS_CHANGED','INVOICE',(int)$invoice['id'],['invoice_number'=>$invoice['invoice_number'],'currency_code'=>$invoice['currency_code'],'status'=>$status]); return $status;
}

function tuman_record_payment(PDO $database, int $teacherId, int $invoiceId, array $input): void
{
    $values=tuman_payment_values($input);$database->beginTransaction();
    try { $invoice=tuman_locked_teacher_invoice($database,$teacherId,$invoiceId); if($invoice===null||!in_array($invoice['status'],['ISSUED','PARTIALLY_PAID'],true)){throw new InvalidArgumentException('Invoice is unavailable for payment.');} $currency=tuman_currency_code((string)$invoice['currency_code']);if($currency===null){throw new RuntimeException('Invoice currency is invalid.');}$paid=tuman_invoice_valid_payment_minor($database,$invoiceId,$currency);$total=tuman_invoice_minor_from_decimal((string)$invoice['total_amount']);if($total===null){throw new RuntimeException('Invoice total is invalid.');}
        $statement=$database->prepare("INSERT INTO tmn_payments (invoice_id,payment_date,amount,currency_code,payment_method,reference_number,remarks,status) VALUES (:invoice_id,:payment_date,:amount,:currency_code,:payment_method,:reference_number,:remarks,'VALID')");$paymentValues=$values;unset($paymentValues['amount_minor']);$statement->execute($paymentValues+['invoice_id'=>$invoiceId,'currency_code'=>$currency]);$paymentId=(int)$database->lastInsertId();$newPaid=$paid+$values['amount_minor'];$status=tuman_update_invoice_payment_status($database,$teacherId,$invoice,$newPaid);if($newPaid>$total){$credit=$newPaid-$total;$creditInsert=$database->prepare("INSERT INTO tmn_student_credits (teacher_student_id,source_payment_id,source_type,received_date,received_method,reference_number,remarks,currency_code,original_amount,remaining_amount,status) VALUES (:assignment_id,:payment_id,'OVERPAYMENT',:received_date,:method,:reference,:remarks,:currency_code,:original_amount,:remaining_amount,'ACTIVE')");$creditInsert->execute(['assignment_id'=>$invoice['teacher_student_id'],'payment_id'=>$paymentId,'received_date'=>$values['payment_date'],'method'=>$values['payment_method'],'reference'=>$values['reference_number'],'remarks'=>$values['remarks'],'currency_code'=>$currency,'original_amount'=>tuman_invoice_decimal_from_minor($credit),'remaining_amount'=>tuman_invoice_decimal_from_minor($credit)]);tuman_log_activity($database,$teacherId,'OVERPAYMENT_CREDIT_CREATED','STUDENT_CREDIT',(int)$database->lastInsertId(),['invoice_number'=>$invoice['invoice_number'],'amount'=>tuman_invoice_decimal_from_minor($credit),'currency_code'=>$currency]);}$meta=['invoice_number'=>$invoice['invoice_number'],'payment_method'=>$values['payment_method'],'amount'=>$values['amount'],'currency_code'=>$currency,'invoice_status'=>$status];tuman_log_activity($database,$teacherId,'PAYMENT_RECORDED','PAYMENT',$paymentId,$meta);$database->commit();
    } catch(Throwable $e){if($database->inTransaction()){$database->rollBack();}throw $e;}
}

function tuman_void_payment(PDO $database, int $teacherId, int $paymentId): void
{
    $database->beginTransaction();try{$payment=tuman_teacher_payment($database,$teacherId,$paymentId);if($payment===null||$payment['status']!=='VALID'){throw new InvalidArgumentException('Payment is unavailable.');}$credit=$database->prepare('SELECT id FROM tmn_student_credits WHERE source_payment_id=:payment_id FOR UPDATE');$credit->execute(['payment_id'=>$paymentId]);if($credit->fetchColumn()!==false){throw new InvalidArgumentException('This payment created an overpayment credit. Apply or refund that credit instead of voiding the payment.');}$invoice=tuman_locked_teacher_invoice($database,$teacherId,(int)$payment['invoice_id']);if($invoice===null){throw new InvalidArgumentException('Payment is unavailable.');}$statement=$database->prepare("UPDATE tmn_payments SET status='VOIDED', voided_at=UTC_TIMESTAMP() WHERE id=:id AND status='VALID'");$statement->execute(['id'=>$paymentId]);if($statement->rowCount()!==1){throw new InvalidArgumentException('Payment is unavailable.');}$paid=tuman_invoice_valid_payment_minor($database,(int)$invoice['id'],(string)$invoice['currency_code']);$status=tuman_update_invoice_payment_status($database,$teacherId,$invoice,$paid);tuman_log_activity($database,$teacherId,'PAYMENT_VOIDED','PAYMENT',$paymentId,['invoice_number'=>$invoice['invoice_number'],'amount'=>$payment['amount'],'currency_code'=>$invoice['currency_code'],'invoice_status'=>$status]);$database->commit();}catch(Throwable $e){if($database->inTransaction()){$database->rollBack();}throw $e;}
}
