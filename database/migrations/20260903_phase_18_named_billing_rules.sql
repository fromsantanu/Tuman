-- Phase 18: named billing rules and optional attendance-to-rule selection.
DELIMITER //
CREATE PROCEDURE tmn_phase_18_add_column(IN table_name_in VARCHAR(64), IN column_name_in VARCHAR(64), IN definition_in TEXT)
BEGIN
 IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=table_name_in AND COLUMN_NAME=column_name_in) THEN
  SET @tmn_phase_18_sql=CONCAT('ALTER TABLE `',table_name_in,'` ADD COLUMN `',column_name_in,'` ',definition_in); PREPARE tmn_phase_18_statement FROM @tmn_phase_18_sql; EXECUTE tmn_phase_18_statement; DEALLOCATE PREPARE tmn_phase_18_statement;
 END IF;
END //
CALL tmn_phase_18_add_column('tmn_student_billing','rule_name','VARCHAR(100) NULL AFTER teacher_student_id') //
CALL tmn_phase_18_add_column('tmn_attendance','billing_rule_id','BIGINT UNSIGNED NULL AFTER teacher_student_id') //
DROP PROCEDURE tmn_phase_18_add_column //
DELIMITER ;
UPDATE tmn_student_billing SET rule_name=CONCAT(CASE WHEN billing_mode='FIXED_MONTHLY' THEN 'Monthly' ELSE 'Hourly' END,' rule #',id) WHERE rule_name IS NULL OR rule_name='';
ALTER TABLE tmn_student_billing ADD UNIQUE KEY uq_tmn_student_billing_assignment_name (teacher_student_id,rule_name);
ALTER TABLE tmn_attendance ADD CONSTRAINT fk_tmn_attendance_billing_rule FOREIGN KEY (billing_rule_id) REFERENCES tmn_student_billing(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
