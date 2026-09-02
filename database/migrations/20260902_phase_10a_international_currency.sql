-- Phase 10A: run once on an existing Tuman database after backing it up.
-- The procedure checks metadata first, so rerunning this migration is safe.
DELIMITER //
CREATE PROCEDURE tmn_phase_10a_add_column(IN table_name_in VARCHAR(64), IN column_name_in VARCHAR(64), IN definition_in TEXT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = table_name_in AND COLUMN_NAME = column_name_in
    ) THEN
        SET @tmn_phase_10a_sql = CONCAT('ALTER TABLE `', table_name_in, '` ADD COLUMN `', column_name_in, '` ', definition_in);
        PREPARE tmn_phase_10a_statement FROM @tmn_phase_10a_sql;
        EXECUTE tmn_phase_10a_statement;
        DEALLOCATE PREPARE tmn_phase_10a_statement;
    END IF;
END //
CALL tmn_phase_10a_add_column('tmn_student_profiles', 'country_code', 'CHAR(2) NULL AFTER postal_code') //
CALL tmn_phase_10a_add_column('tmn_student_billing', 'currency_code', "CHAR(3) NOT NULL DEFAULT 'INR' AFTER rate") //
CALL tmn_phase_10a_add_column('tmn_invoices', 'currency_code', "CHAR(3) NOT NULL DEFAULT 'INR' AFTER total_amount") //
CALL tmn_phase_10a_add_column('tmn_payments', 'currency_code', "CHAR(3) NOT NULL DEFAULT 'INR' AFTER amount") //
DROP PROCEDURE tmn_phase_10a_add_column //
DELIMITER ;

-- Existing rows receive each column default (INR), without changing any amounts or history.
