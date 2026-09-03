-- Tuman Phase 02 schema. Run with a MySQL account allowed to create databases.
CREATE DATABASE IF NOT EXISTS tuman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tuman;

CREATE TABLE IF NOT EXISTS tmn_users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(254) NULL,
    role ENUM('ADMIN','TEACHER','STUDENT') NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_tmn_users_username (username),
    UNIQUE KEY uq_tmn_users_email (email),
    KEY idx_tmn_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_teacher_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    address_line1 VARCHAR(255) NULL,
    address_line2 VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state_name VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    profile_details TEXT NULL,
    photo_path VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_teacher_profiles_user FOREIGN KEY (user_id) REFERENCES tmn_users (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_student_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    address_line1 VARCHAR(255) NULL,
    address_line2 VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state_name VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    country_code CHAR(2) NULL,
    guardian_name VARCHAR(200) NULL,
    guardian_phone VARCHAR(30) NULL,
    profile_details TEXT NULL,
    photo_path VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_student_profiles_user FOREIGN KEY (user_id) REFERENCES tmn_users (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_admin_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    address_line1 VARCHAR(255) NULL,
    address_line2 VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state_name VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    profile_details TEXT NULL,
    photo_path VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_admin_profiles_user FOREIGN KEY (user_id) REFERENCES tmn_users (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_teacher_students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_user_id BIGINT UNSIGNED NOT NULL,
    student_user_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_teacher_students_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT fk_tmn_teacher_students_teacher FOREIGN KEY (teacher_user_id) REFERENCES tmn_users (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_teacher_students_student FOREIGN KEY (student_user_id) REFERENCES tmn_users (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_teacher_students_teacher_status (teacher_user_id, status),
    KEY idx_tmn_teacher_students_student_status (student_user_id, status),
    UNIQUE KEY uq_tmn_teacher_students_pair (teacher_user_id, student_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_responsibilities (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    responsibility_for ENUM('TEACHER','STUDENT') NOT NULL,
    title VARCHAR(200) NOT NULL,
    details TEXT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_responsibilities_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT fk_tmn_responsibilities_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_responsibilities_assignment_status (teacher_student_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_student_billing (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    billing_mode ENUM('FIXED_MONTHLY','HOURLY') NOT NULL,
    rate DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_student_billing_rate CHECK (rate >= 0),
    CONSTRAINT chk_tmn_student_billing_dates CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT fk_tmn_student_billing_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_student_billing_assignment_date (teacher_student_id, effective_from)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    duration_minutes SMALLINT UNSIGNED NULL,
    status ENUM('PRESENT','ABSENT','LEAVE','CANCELLED','HOLIDAY') NOT NULL,
    remarks VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_attendance_time_range CHECK (end_time IS NULL OR start_time IS NULL OR end_time > start_time),
    CONSTRAINT fk_tmn_attendance_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_attendance_session (teacher_student_id, session_date, start_time),
    KEY idx_tmn_attendance_assignment_date (teacher_student_id, session_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_invoice_sequences (
    sequence_scope VARCHAR(30) PRIMARY KEY,
    current_value BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_invoices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50) NOT NULL,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    billing_period_from DATE NOT NULL,
    billing_period_to DATE NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('DRAFT','ISSUED','PARTIALLY_PAID','PAID','CANCELLED') NOT NULL DEFAULT 'DRAFT',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_invoices_period CHECK (billing_period_to >= billing_period_from),
    CONSTRAINT chk_tmn_invoices_amounts CHECK (subtotal >= 0 AND discount_amount >= 0 AND total_amount >= 0),
    CONSTRAINT fk_tmn_invoices_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_invoices_number (invoice_number),
    KEY idx_tmn_invoices_assignment_date (teacher_student_id, invoice_date),
    KEY idx_tmn_invoices_period (billing_period_from, billing_period_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_invoice_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT UNSIGNED NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_rate DECIMAL(12,2) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_invoice_items_values CHECK (quantity > 0 AND unit_rate >= 0 AND amount >= 0),
    CONSTRAINT fk_tmn_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES tmn_invoices (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_invoice_items_invoice_sort (invoice_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT UNSIGNED NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    payment_method ENUM('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NOT NULL,
    reference_number VARCHAR(100) NULL,
    remarks VARCHAR(500) NULL,
    status ENUM('VALID','VOIDED') NOT NULL DEFAULT 'VALID',
    voided_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_payments_amount CHECK (amount > 0),
    CONSTRAINT fk_tmn_payments_invoice FOREIGN KEY (invoice_id) REFERENCES tmn_invoices (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    KEY idx_tmn_payments_invoice_status (invoice_id, status),
    KEY idx_tmn_payments_date (payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_teacher_payment_details (
    teacher_user_id BIGINT UNSIGNED PRIMARY KEY,
    indian_account_holder VARCHAR(200) NULL, indian_bank_name VARCHAR(200) NULL, indian_branch VARCHAR(200) NULL, indian_account_number VARCHAR(100) NULL, indian_ifsc VARCHAR(30) NULL, indian_upi_id VARCHAR(100) NULL, indian_pan_gstin VARCHAR(50) NULL, indian_reference_note VARCHAR(500) NULL,
    international_beneficiary VARCHAR(200) NULL, international_bank_name VARCHAR(200) NULL, international_bank_address VARCHAR(500) NULL, international_account_iban VARCHAR(100) NULL, international_swift_bic VARCHAR(30) NULL, international_intermediary_details VARCHAR(500) NULL, international_fee_note VARCHAR(500) NULL, international_reference_note VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_teacher_payment_details_teacher FOREIGN KEY (teacher_user_id) REFERENCES tmn_users(id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_email_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    related_entity_type VARCHAR(50) NULL,
    related_entity_id BIGINT UNSIGNED NULL,
    recipient_email VARCHAR(254) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    delivery_status ENUM('PENDING','SENT','FAILED') NOT NULL DEFAULT 'PENDING',
    attempted_at DATETIME NULL,
    provider_response VARCHAR(1000) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_tmn_email_log_related_entity (related_entity_type, related_entity_id),
    KEY idx_tmn_email_log_status_created (delivery_status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_system_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value VARCHAR(1000) NOT NULL,
    updated_by_user_id BIGINT UNSIGNED NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_system_settings_user FOREIGN KEY (updated_by_user_id) REFERENCES tmn_users (id) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_activity_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_user_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL,
    entity_id BIGINT UNSIGNED NULL,
    details_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_activity_log_actor FOREIGN KEY (actor_user_id) REFERENCES tmn_users (id) ON DELETE SET NULL ON UPDATE RESTRICT,
    KEY idx_tmn_activity_log_actor_created (actor_user_id, created_at),
    KEY idx_tmn_activity_log_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
