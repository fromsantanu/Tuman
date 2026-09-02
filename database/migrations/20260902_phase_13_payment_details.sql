CREATE TABLE IF NOT EXISTS tmn_teacher_payment_details (
    teacher_user_id BIGINT UNSIGNED PRIMARY KEY,
    indian_account_holder VARCHAR(200) NULL, indian_bank_name VARCHAR(200) NULL, indian_branch VARCHAR(200) NULL,
    indian_account_number VARCHAR(100) NULL, indian_ifsc VARCHAR(30) NULL, indian_upi_id VARCHAR(100) NULL, indian_pan_gstin VARCHAR(50) NULL, indian_reference_note VARCHAR(500) NULL,
    international_beneficiary VARCHAR(200) NULL, international_bank_name VARCHAR(200) NULL, international_bank_address VARCHAR(500) NULL,
    international_account_iban VARCHAR(100) NULL, international_swift_bic VARCHAR(30) NULL, international_intermediary_details VARCHAR(500) NULL, international_fee_note VARCHAR(500) NULL, international_reference_note VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_teacher_payment_details_teacher FOREIGN KEY (teacher_user_id) REFERENCES tmn_users(id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
