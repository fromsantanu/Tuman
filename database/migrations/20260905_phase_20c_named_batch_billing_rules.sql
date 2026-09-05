-- Phase 20 amendment: named rules and multiple instalments per batch.
ALTER TABLE tmn_batch_billing_rules ADD COLUMN rule_code VARCHAR(50) NULL AFTER batch_id;
ALTER TABLE tmn_batch_billing_rules ADD COLUMN rule_name VARCHAR(100) NULL AFTER rule_code;
UPDATE tmn_batch_billing_rules SET rule_code=CONCAT('RULE-',id), rule_name=CONCAT(CASE billing_mode WHEN 'FIXED_MONTHLY' THEN 'Monthly' WHEN 'ONETIME' THEN 'One-time' ELSE 'Instalment' END,' rule ',id) WHERE rule_code IS NULL OR rule_name IS NULL;
ALTER TABLE tmn_batch_billing_rules MODIFY rule_code VARCHAR(50) NOT NULL;
ALTER TABLE tmn_batch_billing_rules MODIFY rule_name VARCHAR(100) NOT NULL;
ALTER TABLE tmn_batch_billing_rules DROP INDEX uq_tmn_batch_billing_rules_mode;
ALTER TABLE tmn_batch_billing_rules ADD UNIQUE KEY uq_tmn_batch_billing_rules_code (batch_id, rule_code);
