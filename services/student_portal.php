<?php
declare(strict_types=1);
require_once __DIR__ . '/invoices.php';

function tuman_student_profile(PDO $database, int $studentId): ?array
{
    $statement=$database->prepare("SELECT u.username,u.email,sp.* FROM tmn_users u INNER JOIN tmn_student_profiles sp ON sp.user_id=u.id WHERE u.id=:student_id AND u.role='STUDENT'");$statement->execute(['student_id'=>$studentId]);$row=$statement->fetch();return is_array($row)?$row:null;
}
function tuman_student_attendance(PDO $database, int $studentId): array
{
    $statement=$database->prepare('SELECT a.* FROM tmn_attendance a INNER JOIN tmn_teacher_students ts ON ts.id=a.teacher_student_id WHERE ts.student_user_id=:student_id ORDER BY a.session_date DESC,a.start_time DESC,a.id DESC');$statement->execute(['student_id'=>$studentId]);return $statement->fetchAll();
}
function tuman_student_invoices(PDO $database, int $studentId): array
{
    $statement=$database->prepare('SELECT i.* FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id WHERE ts.student_user_id=:student_id ORDER BY i.billing_period_from DESC,i.id DESC');$statement->execute(['student_id'=>$studentId]);return $statement->fetchAll();
}
function tuman_student_invoice(PDO $database, int $studentId, int $invoiceId): ?array
{
    $statement=$database->prepare('SELECT i.* FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id WHERE i.id=:invoice_id AND ts.student_user_id=:student_id');$statement->execute(['invoice_id'=>$invoiceId,'student_id'=>$studentId]);$row=$statement->fetch();return is_array($row)?$row:null;
}
function tuman_student_invoice_items(PDO $database, int $studentId, int $invoiceId): array
{
    if(tuman_student_invoice($database,$studentId,$invoiceId)===null){return [];} $statement=$database->prepare('SELECT ii.* FROM tmn_invoice_items ii WHERE ii.invoice_id=:invoice_id ORDER BY ii.sort_order,ii.id');$statement->execute(['invoice_id'=>$invoiceId]);return $statement->fetchAll();
}
function tuman_student_payments(PDO $database, int $studentId): array
{
    $statement=$database->prepare('SELECT p.*,i.invoice_number,i.currency_code FROM tmn_payments p INNER JOIN tmn_invoices i ON i.id=p.invoice_id INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id WHERE ts.student_user_id=:student_id ORDER BY p.payment_date DESC,p.id DESC');$statement->execute(['student_id'=>$studentId]);return $statement->fetchAll();
}
function tuman_student_outstanding_by_currency(PDO $database, int $studentId): array
{
    $statement=$database->prepare("SELECT i.currency_code, i.total_amount, COALESCE(SUM(CASE WHEN p.status='VALID' THEN p.amount ELSE 0 END),0) paid FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id LEFT JOIN tmn_payments p ON p.invoice_id=i.id WHERE ts.student_user_id=:student_id AND i.status IN ('ISSUED','PARTIALLY_PAID') GROUP BY i.id,i.currency_code,i.total_amount");$statement->execute(['student_id'=>$studentId]);$totals=[];foreach($statement->fetchAll() as $row){$currency=$row['currency_code'];$due=tuman_invoice_minor_from_decimal((string)$row['total_amount'])-tuman_invoice_minor_from_decimal((string)$row['paid']);$totals[$currency]=($totals[$currency]??0)+$due;}return $totals;
}
