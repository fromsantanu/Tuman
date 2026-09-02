<?php
declare(strict_types=1);
require_once __DIR__ . '/payments.php';
require_once dirname(__DIR__) . '/config/env.php';

function tuman_queue_invoice_notification(PDO $db,int $teacherId,int $invoiceId,string $type): void
{
    $invoice=tuman_teacher_invoice($db,$teacherId,$invoiceId);if($invoice===null){throw new InvalidArgumentException('Invoice unavailable.');}if(!in_array($type,['INVOICE','REMINDER'],true)||($type==='REMINDER'&&!in_array($invoice['status'],['ISSUED','PARTIALLY_PAID'],true))){throw new InvalidArgumentException('This notification is unavailable.');}if(empty($invoice['email'])){throw new InvalidArgumentException('This student has no email address.');}$amount=tuman_invoice_money_label($invoice['total_amount'],$invoice['currency_code']);$subject=$type==='INVOICE'?'Your Tuman invoice '.$invoice['invoice_number']:'Payment reminder: '.$invoice['invoice_number'];$message=$type==='INVOICE'?"Your invoice {$invoice['invoice_number']} for {$amount} is available.":"Your invoice {$invoice['invoice_number']} has an outstanding balance. Please use the invoice payment instructions.";tuman_queue_email($db,$teacherId,'INVOICE',(int)$invoice['id'],$invoice['email'],$subject,$message,['type'=>$type,'invoice_number'=>$invoice['invoice_number'],'currency_code'=>$invoice['currency_code']]);
}
function tuman_queue_email(PDO $db,int $teacherId,string $entity,int $entityId,string $recipient,string $subject,string $body,array $meta=[]): void
{
    $s=$db->prepare("INSERT INTO tmn_email_log (related_entity_type,related_entity_id,recipient_email,subject,delivery_status,attempted_at,provider_response) VALUES (:type,:id,:recipient,:subject,'PENDING',NULL,NULL)");$s->execute(['type'=>$entity,'id'=>$entityId,'recipient'=>$recipient,'subject'=>$subject]);tuman_log_activity($db,$teacherId,'EMAIL_QUEUED',$entity,$entityId,$meta);
}
