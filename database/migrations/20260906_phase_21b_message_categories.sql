-- Phase 21 amendment: communications use operational categories only.
ALTER TABLE tmn_messages MODIFY category ENUM('ANNOUNCEMENT','REMINDER','WARNING','URGENT_ACTION','OFFICIAL') NOT NULL DEFAULT 'OFFICIAL';
