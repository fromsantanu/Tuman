-- Phase 21: teacher/student messages, recipient notifications, and one optional attachment.
CREATE TABLE IF NOT EXISTS tmn_messages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sender_user_id BIGINT UNSIGNED NOT NULL,
    category ENUM('ANNOUNCEMENT','REMINDER','WARNING','URGENT_ACTION','OFFICIAL') NOT NULL DEFAULT 'OFFICIAL',
    subject VARCHAR(255) NOT NULL,
    message_body MEDIUMTEXT NOT NULL,
    attachment_path VARCHAR(255) NULL,
    attachment_name VARCHAR(255) NULL,
    attachment_mime VARCHAR(100) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_messages_sender FOREIGN KEY (sender_user_id) REFERENCES tmn_users(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_messages_sender_created (sender_user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_message_recipients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    message_id BIGINT UNSIGNED NOT NULL,
    recipient_user_id BIGINT UNSIGNED NOT NULL,
    email_log_id BIGINT UNSIGNED NULL,
    read_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_message_recipients_message FOREIGN KEY (message_id) REFERENCES tmn_messages(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_message_recipients_user FOREIGN KEY (recipient_user_id) REFERENCES tmn_users(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_message_recipients_email_log FOREIGN KEY (email_log_id) REFERENCES tmn_email_log(id) ON DELETE SET NULL ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_message_recipient (message_id, recipient_user_id),
    KEY idx_tmn_message_recipients_unread (recipient_user_id, read_at, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
