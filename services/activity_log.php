<?php
declare(strict_types=1);

/** Records a safe audit event. Passwords and password hashes must never be passed here. */
function tuman_log_activity(PDO $database, int $actorUserId, string $action, string $entityType, ?int $entityId, array $details = []): void
{
    $statement = $database->prepare(
        'INSERT INTO tmn_activity_log (actor_user_id, action, entity_type, entity_id, details_json)
         VALUES (:actor_user_id, :action, :entity_type, :entity_id, :details_json)'
    );
    $statement->execute([
        'actor_user_id' => $actorUserId,
        'action' => $action,
        'entity_type' => $entityType,
        'entity_id' => $entityId,
        'details_json' => json_encode($details, JSON_THROW_ON_ERROR),
    ]);
}
