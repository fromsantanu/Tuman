-- Batch billing is selected when invoices are generated, never when attendance is recorded.
ALTER TABLE tmn_invoices ADD COLUMN batch_billing_rule_id BIGINT UNSIGNED NULL AFTER batch_id;
ALTER TABLE tmn_invoices ADD CONSTRAINT fk_tmn_invoices_batch_billing_rule FOREIGN KEY (batch_billing_rule_id) REFERENCES tmn_batch_billing_rules(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tmn_invoices ADD KEY idx_tmn_invoices_batch_rule_period (batch_billing_rule_id, billing_period_from, billing_period_to);
