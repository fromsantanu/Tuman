<?php
declare(strict_types=1);
require_once __DIR__ . '/payments.php';
require_once dirname(__DIR__) . '/config/env.php';
require_once dirname(__DIR__) . '/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;

function tuman_queue_invoice_notification(PDO $db,int $teacherId,int $invoiceId,string $type): string
{
    $invoice=tuman_teacher_invoice($db,$teacherId,$invoiceId);if($invoice===null){throw new InvalidArgumentException('Invoice unavailable.');}if(!in_array($type,['INVOICE','REMINDER'],true)||($type==='REMINDER'&&!in_array($invoice['status'],['ISSUED','PARTIALLY_PAID'],true))){throw new InvalidArgumentException('This notification is unavailable.');}if(empty($invoice['email'])){throw new InvalidArgumentException('This student has no email address.');}$amount=tuman_invoice_money_label($invoice['total_amount'],$invoice['currency_code']);$subject=$type==='INVOICE'?'Your Tuman invoice '.$invoice['invoice_number']:'Payment reminder: '.$invoice['invoice_number'];$message=$type==='INVOICE'?"Your invoice {$invoice['invoice_number']} for {$amount} is available.":"Your invoice {$invoice['invoice_number']} has an outstanding balance. Please use the invoice payment instructions.";$logId=tuman_queue_email($db,$teacherId,'INVOICE',(int)$invoice['id'],$invoice['email'],$subject,$message,['type'=>$type,'invoice_number'=>$invoice['invoice_number'],'currency_code'=>$invoice['currency_code']]);return tuman_deliver_email($db,$logId,$invoice['email'],$subject,$message);
}
function tuman_queue_email(PDO $db,int $teacherId,string $entity,int $entityId,string $recipient,string $subject,string $body,array $meta=[]): int
{
    $s=$db->prepare("INSERT INTO tmn_email_log (related_entity_type,related_entity_id,recipient_email,subject,delivery_status,attempted_at,provider_response) VALUES (:type,:id,:recipient,:subject,'PENDING',NULL,NULL)");$s->execute(['type'=>$entity,'id'=>$entityId,'recipient'=>$recipient,'subject'=>$subject]);tuman_log_activity($db,$teacherId,'EMAIL_QUEUED',$entity,$entityId,$meta);return (int)$db->lastInsertId();
}

function tuman_deliver_email(PDO $db,int $logId,string $recipient,string $subject,string $body): string
{
    $environment=tuman_environment();if(strtolower($environment['MAIL_ENABLED']??'false')!=='true'){return 'PENDING';}
    try { foreach(['MAIL_HOST','MAIL_PORT','MAIL_USERNAME','MAIL_PASSWORD','MAIL_FROM_ADDRESS'] as $key){if(($environment[$key]??'')===''){throw new RuntimeException('SMTP configuration is incomplete.');}}
        $mail=new PHPMailer(true);$mail->isSMTP();$mail->Host=$environment['MAIL_HOST'];$mail->Port=(int)$environment['MAIL_PORT'];$mail->SMTPAuth=true;$mail->Username=$environment['MAIL_USERNAME'];$mail->Password=$environment['MAIL_PASSWORD'];$encryption=strtolower($environment['MAIL_ENCRYPTION']??'tls');if($encryption==='ssl'){$mail->SMTPSecure=PHPMailer::ENCRYPTION_SMTPS;}elseif($encryption==='tls'){$mail->SMTPSecure=PHPMailer::ENCRYPTION_STARTTLS;}else{$mail->SMTPAutoTLS=false;}$mail->CharSet='UTF-8';$mail->setFrom($environment['MAIL_FROM_ADDRESS'],$environment['MAIL_FROM_NAME']??'Tuman');$mail->addAddress($recipient);$mail->Subject=$subject;$mail->isHTML(true);$mail->Body=nl2br(htmlspecialchars($body,ENT_QUOTES,'UTF-8'));$mail->AltBody=$body;$mail->send();tuman_update_email_delivery($db,$logId,'SENT','Delivered through SMTP.');return 'SENT';
    } catch(Throwable $exception) {error_log('Tuman SMTP delivery failed: '.$exception->getMessage());tuman_update_email_delivery($db,$logId,'FAILED','SMTP delivery failed. Check the mail settings and server log.');return 'FAILED';}
}
function tuman_update_email_delivery(PDO $db,int $logId,string $status,string $response): void
{
    $statement=$db->prepare('UPDATE tmn_email_log SET delivery_status=:status,attempted_at=UTC_TIMESTAMP(),provider_response=:response WHERE id=:id');$statement->execute(['status'=>$status,'response'=>substr($response,0,1000),'id'=>$logId]);
}
