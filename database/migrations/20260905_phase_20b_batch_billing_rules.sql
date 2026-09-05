-- Phase 20 amendment: batches can offer multiple independently priced billing rules.
CREATE TABLE IF NOT EXISTS tmn_batch_billing_rules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT UNSIGNED NOT NULL,
    billing_mode ENUM('FIXED_MONTHLY','INSTALLMENTS','ONETIME') NOT NULL,
    charge DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_batch_billing_rules_charge CHECK (charge >= 0),
    CONSTRAINT fk_tmn_batch_billing_rules_batch FOREIGN KEY (batch_id) REFERENCES tmn_batches(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_batch_billing_rules_mode (batch_id, billing_mode),
    KEY idx_tmn_batch_billing_rules_batch_status (batch_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO tmn_batch_billing_rules (batch_id, billing_mode, charge, currency_code, status)
SELECT id, billing_mode, charge, currency_code, status FROM tmn_batches;

ALTER TABLE tmn_attendance ADD COLUMN batch_billing_rule_id BIGINT UNSIGNED NULL AFTER batch_id;
ALTER TABLE tmn_attendance ADD CONSTRAINT fk_tmn_attendance_batch_billing_rule FOREIGN KEY (batch_billing_rule_id) REFERENCES tmn_batch_billing_rules(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
