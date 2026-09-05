-- Phase 21: administrator database-backup and operational-data retention history.
CREATE TABLE IF NOT EXISTS tmn_backup_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    initiated_by_user_id BIGINT UNSIGNED NULL,
    status ENUM('RUNNING','SUCCEEDED','FAILED') NOT NULL DEFAULT 'RUNNING',
    storage_identifier VARCHAR(255) NULL,
    file_size_bytes BIGINT UNSIGNED NULL,
    error_summary VARCHAR(500) NULL,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    CONSTRAINT fk_tmn_backup_runs_initiator FOREIGN KEY (initiated_by_user_id) REFERENCES tmn_users(id) ON DELETE SET NULL ON UPDATE RESTRICT,
    KEY idx_tmn_backup_runs_status_completed (status, completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_purge_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    initiated_by_user_id BIGINT UNSIGNED NULL,
    backup_run_id BIGINT UNSIGNED NULL,
    mode ENUM('PREVIEW','EXECUTED') NOT NULL,
    cutoff_date DATE NOT NULL,
    status ENUM('RUNNING','SUCCEEDED','FAILED') NOT NULL DEFAULT 'RUNNING',
    row_counts_json JSON NULL,
    error_summary VARCHAR(500) NULL,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    CONSTRAINT fk_tmn_purge_runs_initiator FOREIGN KEY (initiated_by_user_id) REFERENCES tmn_users(id) ON DELETE SET NULL ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_purge_runs_backup FOREIGN KEY (backup_run_id) REFERENCES tmn_backup_runs(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_purge_runs_status_completed (status, completed_at),
    KEY idx_tmn_purge_runs_cutoff (cutoff_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
