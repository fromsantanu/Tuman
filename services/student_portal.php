<?php
declare(strict_types=1);
require_once __DIR__ . '/invoices.php';

function tuman_student_profile(PDO $database, int $studentId): ?array
{
    $statement=$database->prepare("SELECT u.username,u.email,sp.* FROM tmn_users u INNER JOIN tmn_student_profiles sp ON sp.user_id=u.id WHERE u.id=:student_id AND u.role='STUDENT'");$statement->execute(['student_id'=>$studentId]);$row=$statement->fetch();return is_array($row)?$row:null;
}
function tuman_student_teacher_assignments(PDO $database, int $studentId): array
{
    $statement=$database->prepare("SELECT ts.id AS assignment_id, u.id AS teacher_user_id, COALESCE(NULLIF(tp.first_name, ''), u.username) AS first_name, tp.last_name FROM tmn_teacher_students ts INNER JOIN tmn_users u ON u.id=ts.teacher_user_id LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=u.id WHERE ts.student_user_id=:student_id ORDER BY first_name,tp.last_name");$statement->execute(['student_id'=>$studentId]);return $statement->fetchAll();
}
/** @return array<string, mixed>|null */
function tuman_student_teacher_profile(PDO $database, int $studentId, mixed $assignmentValue): ?array
{
    $assignmentId = filter_var($assignmentValue, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    if ($assignmentId === false) { return null; }
    $statement = $database->prepare("SELECT ts.id AS assignment_id, ts.status AS assignment_status, ts.start_date, ts.end_date, u.username, u.email, tp.first_name, tp.last_name, tp.phone, tp.address_line1, tp.address_line2, tp.city, tp.state_name, tp.postal_code, tp.profile_details, tp.photo_path FROM tmn_teacher_students ts INNER JOIN tmn_users u ON u.id=ts.teacher_user_id AND u.role='TEACHER' LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=u.id WHERE ts.id=:assignment_id AND ts.student_user_id=:student_id");
    $statement->execute(['assignment_id' => $assignmentId, 'student_id' => $studentId]);
    $row = $statement->fetch();
    return is_array($row) ? $row : null;
}
function tuman_student_owned_assignment_id(PDO $database,int $studentId,mixed $value): ?int
{
    if($value===null||$value===''){return null;}$id=filter_var($value,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);if(!$id){throw new InvalidArgumentException('Teacher filter unavailable.');}$statement=$database->prepare('SELECT id FROM tmn_teacher_students WHERE id=:id AND student_user_id=:student_id');$statement->execute(['id'=>$id,'student_id'=>$studentId]);if($statement->fetchColumn()===false){throw new InvalidArgumentException('Teacher filter unavailable.');}return (int)$id;
}
function tuman_student_attendance(PDO $database, int $studentId, ?int $assignmentId = null): array
{
    $sql="SELECT a.*, COALESCE(NULLIF(tp.first_name, ''), u.username) AS teacher_first_name, tp.last_name AS teacher_last_name FROM tmn_attendance a INNER JOIN tmn_teacher_students ts ON ts.id=a.teacher_student_id INNER JOIN tmn_users u ON u.id=ts.teacher_user_id LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=ts.teacher_user_id WHERE ts.student_user_id=:student_id";$params=['student_id'=>$studentId];if($assignmentId!==null){$sql.=' AND ts.id=:assignment_id';$params['assignment_id']=$assignmentId;}$sql.=' ORDER BY a.session_date DESC,a.start_time DESC,a.id DESC';$statement=$database->prepare($sql);$statement->execute($params);return $statement->fetchAll();
}
function tuman_student_invoices(PDO $database, int $studentId, ?int $assignmentId = null): array
{
    $sql="SELECT i.*, COALESCE(NULLIF(tp.first_name, ''), u.username) AS teacher_first_name, tp.last_name AS teacher_last_name FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id INNER JOIN tmn_users u ON u.id=ts.teacher_user_id LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=ts.teacher_user_id WHERE ts.student_user_id=:student_id";$params=['student_id'=>$studentId];if($assignmentId!==null){$sql.=' AND ts.id=:assignment_id';$params['assignment_id']=$assignmentId;}$sql.=' ORDER BY i.billing_period_from DESC,i.id DESC';$statement=$database->prepare($sql);$statement->execute($params);return $statement->fetchAll();
}
function tuman_student_invoice(PDO $database, int $studentId, int $invoiceId): ?array
{
    $statement=$database->prepare('SELECT i.* FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id WHERE i.id=:invoice_id AND ts.student_user_id=:student_id');$statement->execute(['invoice_id'=>$invoiceId,'student_id'=>$studentId]);$row=$statement->fetch();return is_array($row)?$row:null;
}
function tuman_student_invoice_items(PDO $database, int $studentId, int $invoiceId): array
{
    if(tuman_student_invoice($database,$studentId,$invoiceId)===null){return [];} $statement=$database->prepare('SELECT ii.* FROM tmn_invoice_items ii WHERE ii.invoice_id=:invoice_id ORDER BY ii.sort_order,ii.id');$statement->execute(['invoice_id'=>$invoiceId]);return $statement->fetchAll();
}
function tuman_student_payments(PDO $database, int $studentId, ?int $assignmentId = null): array
{
    $sql="SELECT p.*,i.invoice_number,i.currency_code,COALESCE(NULLIF(tp.first_name, ''), u.username) AS teacher_first_name,tp.last_name AS teacher_last_name FROM tmn_payments p INNER JOIN tmn_invoices i ON i.id=p.invoice_id INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id INNER JOIN tmn_users u ON u.id=ts.teacher_user_id LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=ts.teacher_user_id WHERE ts.student_user_id=:student_id";$params=['student_id'=>$studentId];if($assignmentId!==null){$sql.=' AND ts.id=:assignment_id';$params['assignment_id']=$assignmentId;}$sql.=' ORDER BY p.payment_date DESC,p.id DESC';$statement=$database->prepare($sql);$statement->execute($params);return $statement->fetchAll();
}
function tuman_student_outstanding_by_currency(PDO $database, int $studentId): array
{
    $statement=$database->prepare("SELECT i.currency_code, i.total_amount, COALESCE(SUM(CASE WHEN p.status='VALID' THEN p.amount ELSE 0 END),0) paid FROM tmn_invoices i INNER JOIN tmn_teacher_students ts ON ts.id=i.teacher_student_id LEFT JOIN tmn_payments p ON p.invoice_id=i.id WHERE ts.student_user_id=:student_id AND i.status IN ('ISSUED','PARTIALLY_PAID') GROUP BY i.id,i.currency_code,i.total_amount");$statement->execute(['student_id'=>$studentId]);$totals=[];foreach($statement->fetchAll() as $row){$currency=$row['currency_code'];$due=tuman_invoice_minor_from_decimal((string)$row['total_amount'])-tuman_invoice_minor_from_decimal((string)$row['paid']);$totals[$currency]=($totals[$currency]??0)+$due;}return $totals;
}
