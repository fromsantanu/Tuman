-- Phase 22: optional metadata for teacher-created special invoices.
ALTER TABLE tmn_invoices
    ADD COLUMN special_reason ENUM('ADDITIONAL_CHARGES','COMPENSATION','OTHER') NULL AFTER currency_code,
    ADD COLUMN special_comment VARCHAR(500) NULL AFTER special_reason;
