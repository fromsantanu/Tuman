<?php
declare(strict_types=1);

require_once __DIR__ . '/notifications.php';
require_once __DIR__ . '/batches.php';

const TUMAN_MESSAGE_CATEGORIES = ['ANNOUNCEMENT', 'REMINDER', 'WARNING', 'URGENT_ACTION', 'OFFICIAL'];
const TUMAN_MESSAGE_MAX_ATTACHMENT_BYTES = 10485760;

function tuman_message_category_label(string $category): string { return ucwords(strtolower(str_replace('_', ' ', $category))); }

/** @return array<string,mixed> */
function tuman_message_values(array $input): array {
    $category = strtoupper(trim((string)($input['category'] ?? 'PERSONAL')));
    $subject = trim((string)($input['subject'] ?? ''));
    $body = trim((string)($input['message_body'] ?? ''));
    if (!in_array($category, TUMAN_MESSAGE_CATEGORIES, true) || $subject === '' || strlen($subject) > 255 || $body === '' || strlen($body) > 50000) {
        throw new InvalidArgumentException('Choose a category and enter a subject (255 characters or fewer) and message (50,000 characters or fewer).');
    }
    return ['category' => $category, 'subject' => $subject, 'message_body' => $body];
}

/** @return array{path:?string,name:?string,mime:?string} */
function tuman_store_message_attachment(array $upload): array {
    if (($upload['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) return ['path' => null, 'name' => null, 'mime' => null];
    if (($upload['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK || !is_uploaded_file((string)($upload['tmp_name'] ?? ''))) throw new InvalidArgumentException('The attachment could not be uploaded.');
    if ((int)($upload['size'] ?? 0) < 1 || (int)$upload['size'] > TUMAN_MESSAGE_MAX_ATTACHMENT_BYTES) throw new InvalidArgumentException('Attachments must be no larger than 10 MB.');
    $mime = (new finfo(FILEINFO_MIME_TYPE))->file((string)$upload['tmp_name']);
    $allowed = ['application/pdf' => 'pdf', 'image/jpeg' => 'jpg', 'image/png' => 'png', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx', 'application/msword' => 'doc'];
    if (!isset($allowed[$mime])) throw new InvalidArgumentException('Attachments must be a PDF, JPG, PNG, DOC, or DOCX file.');
    $directory = dirname(__DIR__) . '/uploads/message-attachments';
    if (!is_dir($directory) && !mkdir($directory, 0755, true) && !is_dir($directory)) throw new RuntimeException('The attachment folder could not be created.');
    $filename = bin2hex(random_bytes(20)) . '.' . $allowed[$mime];
    if (!move_uploaded_file((string)$upload['tmp_name'], $directory . '/' . $filename)) throw new RuntimeException('The attachment could not be saved.');
    return ['path' => '/uploads/message-attachments/' . $filename, 'name' => substr(basename((string)$upload['name']), 0, 255), 'mime' => $mime];
}

/** @return list<array<string,mixed>> */
function tuman_message_recipients_for_teacher(PDO $db, int $teacherId, string $mode, mixed $target): array {
    $id = filter_var($target, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    if (!$id) throw new InvalidArgumentException('Choose a recipient.');
    if ($mode === 'STUDENT') {
        $s = $db->prepare("SELECT ts.student_user_id user_id,u.email FROM tmn_teacher_students ts INNER JOIN tmn_users u ON u.id=ts.student_user_id WHERE ts.id=:id AND ts.teacher_user_id=:teacher AND ts.status='ACTIVE' AND u.status='ACTIVE'");
        $s->execute(['id' => $id, 'teacher' => $teacherId]);
    } elseif ($mode === 'BATCH') {
        $s = $db->prepare("SELECT DISTINCT ts.student_user_id user_id,u.email FROM tmn_batch_students bs INNER JOIN tmn_batches b ON b.id=bs.batch_id INNER JOIN tmn_teacher_students ts ON ts.id=bs.teacher_student_id INNER JOIN tmn_users u ON u.id=ts.student_user_id WHERE b.id=:id AND b.teacher_user_id=:teacher AND b.status='ACTIVE' AND bs.status='ACTIVE' AND ts.status='ACTIVE' AND u.status='ACTIVE'");
        $s->execute(['id' => $id, 'teacher' => $teacherId]);
    } else throw new InvalidArgumentException('Choose whether to message one student or a batch.');
    $rows = $s->fetchAll(); if ($rows === []) throw new InvalidArgumentException('There are no active recipients for that selection.'); return $rows;
}

/** @return list<array<string,mixed>> */
function tuman_message_recipients_for_student(PDO $db, int $studentId, mixed $assignmentId): array {
    $id = filter_var($assignmentId, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    if (!$id) throw new InvalidArgumentException('Choose a teacher.');
    $s = $db->prepare("SELECT ts.teacher_user_id user_id,u.email FROM tmn_teacher_students ts INNER JOIN tmn_users u ON u.id=ts.teacher_user_id WHERE ts.id=:id AND ts.student_user_id=:student AND ts.status='ACTIVE' AND u.status='ACTIVE'");
    $s->execute(['id' => $id, 'student' => $studentId]); $rows = $s->fetchAll(); if ($rows === []) throw new InvalidArgumentException('That teacher is unavailable.'); return $rows;
}

function tuman_send_message(PDO $db, int $senderId, array $values, array $recipients, array $attachment): int {
    $db->beginTransaction();
    try {
        $s = $db->prepare('INSERT INTO tmn_messages (sender_user_id,category,subject,message_body,attachment_path,attachment_name,attachment_mime) VALUES (:sender,:category,:subject,:body,:path,:name,:mime)');
        $s->execute(['sender'=>$senderId,'category'=>$values['category'],'subject'=>$values['subject'],'body'=>$values['message_body'],'path'=>$attachment['path'],'name'=>$attachment['name'],'mime'=>$attachment['mime']]);
        $messageId = (int)$db->lastInsertId(); $r = $db->prepare('INSERT INTO tmn_message_recipients (message_id,recipient_user_id) VALUES (:message,:recipient)');
        foreach ($recipients as $recipient) $r->execute(['message'=>$messageId,'recipient'=>$recipient['user_id']]);
        tuman_log_activity($db, $senderId, 'MESSAGE_SENT', 'MESSAGE', $messageId, ['category'=>$values['category'],'recipient_count'=>count($recipients)]);
        $db->commit();
    } catch (Throwable $e) { if ($db->inTransaction()) $db->rollBack(); throw $e; }
    foreach ($recipients as $recipient) {
        if (filter_var($recipient['email'] ?? '', FILTER_VALIDATE_EMAIL) === false) continue;
        $logId = tuman_queue_email($db, $senderId, 'MESSAGE', $messageId, $recipient['email'], '[' . tuman_message_category_label($values['category']) . '] ' . $values['subject'], $values['message_body']);
        $db->prepare('UPDATE tmn_message_recipients SET email_log_id=:log WHERE message_id=:message AND recipient_user_id=:recipient')->execute(['log'=>$logId,'message'=>$messageId,'recipient'=>$recipient['user_id']]);
        tuman_deliver_email($db, $logId, $recipient['email'], '[' . tuman_message_category_label($values['category']) . '] ' . $values['subject'], $values['message_body'], $attachment['path']);
    }
    return $messageId;
}

/** @return list<array<string,mixed>> */
function tuman_messages_for_recipient(PDO $db, int $userId): array {
    $s=$db->prepare("SELECT m.*,mr.read_at,COALESCE(NULLIF(tp.first_name,''),NULLIF(sp.first_name,''),u.username) sender_first_name,COALESCE(tp.last_name,sp.last_name,'') sender_last_name FROM tmn_message_recipients mr INNER JOIN tmn_messages m ON m.id=mr.message_id INNER JOIN tmn_users u ON u.id=m.sender_user_id LEFT JOIN tmn_teacher_profiles tp ON tp.user_id=u.id LEFT JOIN tmn_student_profiles sp ON sp.user_id=u.id WHERE mr.recipient_user_id=:user ORDER BY m.created_at DESC,m.id DESC"); $s->execute(['user'=>$userId]); return $s->fetchAll();
}
function tuman_unread_message_count(PDO $db, int $userId): int { $s=$db->prepare('SELECT COUNT(*) FROM tmn_message_recipients WHERE recipient_user_id=:user AND read_at IS NULL');$s->execute(['user'=>$userId]);return (int)$s->fetchColumn(); }
/** @return array<string,mixed>|null */
function tuman_message_for_recipient(PDO $db,int $userId,int $messageId): ?array { $s=$db->prepare('SELECT m.*,mr.read_at FROM tmn_messages m INNER JOIN tmn_message_recipients mr ON mr.message_id=m.id WHERE m.id=:message AND mr.recipient_user_id=:user');$s->execute(['message'=>$messageId,'user'=>$userId]);$row=$s->fetch();if(!is_array($row))return null;if($row['read_at']===null)$db->prepare('UPDATE tmn_message_recipients SET read_at=UTC_TIMESTAMP() WHERE message_id=:message AND recipient_user_id=:user')->execute(['message'=>$messageId,'user'=>$userId]);return $row; }
