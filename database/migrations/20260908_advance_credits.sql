-- Allow a Teacher to record money received before an invoice exists.
-- Existing overpayment credits retain their original source and behaviour.
ALTER TABLE tmn_student_credits
    MODIFY source_payment_id BIGINT UNSIGNED NULL,
    ADD COLUMN source_type ENUM('OVERPAYMENT','ADVANCE') NOT NULL DEFAULT 'OVERPAYMENT' AFTER source_payment_id,
    ADD COLUMN received_date DATE NULL AFTER source_type,
    ADD COLUMN received_method ENUM('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NULL AFTER received_date,
    ADD COLUMN reference_number VARCHAR(100) NULL AFTER received_method,
    ADD COLUMN remarks VARCHAR(500) NULL AFTER reference_number;
