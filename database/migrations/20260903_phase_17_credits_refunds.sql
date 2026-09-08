-- Phase 17: overpayment credits, credit applications, and credit refunds.
CREATE TABLE IF NOT EXISTS tmn_student_credits (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    source_payment_id BIGINT UNSIGNED NULL,
    source_type ENUM('OVERPAYMENT','ADVANCE') NOT NULL DEFAULT 'OVERPAYMENT',
    received_date DATE NULL,
    received_method ENUM('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NULL,
    reference_number VARCHAR(100) NULL,
    remarks VARCHAR(500) NULL,
    currency_code CHAR(3) NOT NULL,
    original_amount DECIMAL(12,2) NOT NULL,
    remaining_amount DECIMAL(12,2) NOT NULL,
    status ENUM('ACTIVE','EXHAUSTED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_student_credits_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_student_credits_payment FOREIGN KEY (source_payment_id) REFERENCES tmn_payments(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_tmn_student_credits_amounts CHECK (original_amount > 0 AND remaining_amount >= 0 AND remaining_amount <= original_amount),
    UNIQUE KEY uq_tmn_student_credits_source_payment (source_payment_id),
    KEY idx_tmn_student_credits_assignment_currency (teacher_student_id,currency_code,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_credit_applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    credit_id BIGINT UNSIGNED NOT NULL,
    invoice_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_credit_applications_credit FOREIGN KEY (credit_id) REFERENCES tmn_student_credits(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_credit_applications_invoice FOREIGN KEY (invoice_id) REFERENCES tmn_invoices(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_tmn_credit_applications_amount CHECK (amount > 0),
    KEY idx_tmn_credit_applications_credit (credit_id), KEY idx_tmn_credit_applications_invoice (invoice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_credit_refunds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    credit_id BIGINT UNSIGNED NOT NULL,
    refund_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    refund_method ENUM('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NOT NULL,
    reference_number VARCHAR(100) NULL,
    remarks VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_credit_refunds_credit FOREIGN KEY (credit_id) REFERENCES tmn_student_credits(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_tmn_credit_refunds_amount CHECK (amount > 0), KEY idx_tmn_credit_refunds_credit_date (credit_id,refund_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
