-- Phase 20: teacher batches, memberships, batch attendance and batch invoice origin.
CREATE TABLE IF NOT EXISTS tmn_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_user_id BIGINT UNSIGNED NOT NULL,
    batch_name VARCHAR(150) NOT NULL,
    objective TEXT NULL,
    teacher_responsibility TEXT NULL,
    student_responsibility TEXT NULL,
    batch_terms TEXT NULL,
    billing_mode ENUM('FIXED_MONTHLY','INSTALLMENTS','ONETIME') NOT NULL,
    charge DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tmn_batches_charge CHECK (charge >= 0),
    CONSTRAINT fk_tmn_batches_teacher FOREIGN KEY (teacher_user_id) REFERENCES tmn_users(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_batches_teacher_name (teacher_user_id, batch_name),
    KEY idx_tmn_batches_teacher_status (teacher_user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tmn_batch_students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT UNSIGNED NOT NULL,
    teacher_student_id BIGINT UNSIGNED NOT NULL,
    enrolled_on DATE NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tmn_batch_students_batch FOREIGN KEY (batch_id) REFERENCES tmn_batches(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_tmn_batch_students_assignment FOREIGN KEY (teacher_student_id) REFERENCES tmn_teacher_students(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    UNIQUE KEY uq_tmn_batch_students_member (batch_id, teacher_student_id),
    KEY idx_tmn_batch_students_assignment_status (teacher_student_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE tmn_attendance ADD COLUMN batch_id BIGINT UNSIGNED NULL AFTER billing_rule_id;
ALTER TABLE tmn_attendance ADD CONSTRAINT fk_tmn_attendance_batch FOREIGN KEY (batch_id) REFERENCES tmn_batches(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tmn_attendance ADD KEY idx_tmn_attendance_batch_date (batch_id, session_date);
ALTER TABLE tmn_invoices ADD COLUMN batch_id BIGINT UNSIGNED NULL AFTER teacher_student_id;
ALTER TABLE tmn_invoices ADD CONSTRAINT fk_tmn_invoices_batch FOREIGN KEY (batch_id) REFERENCES tmn_batches(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tmn_invoices ADD KEY idx_tmn_invoices_batch_period (batch_id, billing_period_from, billing_period_to);
