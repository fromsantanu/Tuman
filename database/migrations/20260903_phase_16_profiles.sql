-- Phase 16: personal profiles and teacher-visible student contact details.
-- Safe to rerun on an existing Tuman database.
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

DELIMITER //
CREATE PROCEDURE tmn_phase_16_add_column(IN table_name_in VARCHAR(64), IN column_name_in VARCHAR(64), IN definition_in TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = table_name_in AND COLUMN_NAME = column_name_in) THEN
        SET @tmn_phase_16_sql = CONCAT('ALTER TABLE `', table_name_in, '` ADD COLUMN `', column_name_in, '` ', definition_in);
        PREPARE tmn_phase_16_statement FROM @tmn_phase_16_sql;
        EXECUTE tmn_phase_16_statement;
        DEALLOCATE PREPARE tmn_phase_16_statement;
    END IF;
END //
CALL tmn_phase_16_add_column('tmn_teacher_profiles', 'profile_details', 'TEXT NULL AFTER postal_code') //
CALL tmn_phase_16_add_column('tmn_teacher_profiles', 'photo_path', 'VARCHAR(255) NULL AFTER profile_details') //
CALL tmn_phase_16_add_column('tmn_student_profiles', 'profile_details', 'TEXT NULL AFTER guardian_phone') //
CALL tmn_phase_16_add_column('tmn_student_profiles', 'photo_path', 'VARCHAR(255) NULL AFTER profile_details') //
DROP PROCEDURE tmn_phase_16_add_column //
DELIMITER ;
