-- Development-only fictional data. Every account uses password: TumanDemo2026!
USE tuman;

INSERT IGNORE INTO tmn_users (username, password_hash, email, role, status) VALUES
('admin.demo', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'admin.demo@example.test', 'ADMIN', 'ACTIVE'),
('teacher.aisha', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'aisha@example.test', 'TEACHER', 'ACTIVE'),
('teacher.rahul', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'rahul@example.test', 'TEACHER', 'ACTIVE'),
('student.kavya', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'kavya@example.test', 'STUDENT', 'ACTIVE'),
('student.arjun', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'arjun@example.test', 'STUDENT', 'ACTIVE'),
('student.meera', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'meera@example.test', 'STUDENT', 'ACTIVE'),
('student.rohan', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'rohan@example.test', 'STUDENT', 'ACTIVE');

INSERT IGNORE INTO tmn_teacher_profiles (user_id, first_name, last_name, phone, city)
SELECT id, 'Aisha', 'Khan', '9000000001', 'Pune' FROM tmn_users WHERE username = 'teacher.aisha';
INSERT IGNORE INTO tmn_teacher_profiles (user_id, first_name, last_name, phone, city)
SELECT id, 'Rahul', 'Verma', '9000000002', 'Pune' FROM tmn_users WHERE username = 'teacher.rahul';

INSERT IGNORE INTO tmn_student_profiles (user_id, first_name, last_name, phone, city, guardian_name, guardian_phone)
SELECT id, 'Kavya', 'Sharma', '9000000011', 'Pune', 'Neha Sharma', '9000001011' FROM tmn_users WHERE username = 'student.kavya';
INSERT IGNORE INTO tmn_student_profiles (user_id, first_name, last_name, phone, city, guardian_name, guardian_phone)
SELECT id, 'Arjun', 'Patel', '9000000012', 'Pune', 'Ravi Patel', '9000001012' FROM tmn_users WHERE username = 'student.arjun';
INSERT IGNORE INTO tmn_student_profiles (user_id, first_name, last_name, phone, city, guardian_name, guardian_phone)
SELECT id, 'Meera', 'Iyer', '9000000013', 'Pune', 'Lakshmi Iyer', '9000001013' FROM tmn_users WHERE username = 'student.meera';
INSERT IGNORE INTO tmn_student_profiles (user_id, first_name, last_name, phone, city, guardian_name, guardian_phone)
SELECT id, 'Rohan', 'Das', '9000000014', 'Pune', 'Anita Das', '9000001014' FROM tmn_users WHERE username = 'student.rohan';

INSERT IGNORE INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status)
SELECT t.id, s.id, '2026-01-01', 'ACTIVE' FROM tmn_users t CROSS JOIN tmn_users s WHERE t.username = 'teacher.aisha' AND s.username = 'student.kavya';
INSERT IGNORE INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status)
SELECT t.id, s.id, '2026-01-01', 'ACTIVE' FROM tmn_users t CROSS JOIN tmn_users s WHERE t.username = 'teacher.aisha' AND s.username = 'student.arjun';
INSERT IGNORE INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status)
SELECT t.id, s.id, '2026-01-01', 'ACTIVE' FROM tmn_users t CROSS JOIN tmn_users s WHERE t.username = 'teacher.rahul' AND s.username = 'student.meera';
INSERT IGNORE INTO tmn_teacher_students (teacher_user_id, student_user_id, start_date, status)
SELECT t.id, s.id, '2026-01-01', 'ACTIVE' FROM tmn_users t CROSS JOIN tmn_users s WHERE t.username = 'teacher.rahul' AND s.username = 'student.rohan';

INSERT IGNORE INTO tmn_responsibilities (teacher_student_id, responsibility_for, title, effective_from)
SELECT ts.id, 'TEACHER', 'Provide regular assignments', '2026-01-01' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';
INSERT IGNORE INTO tmn_responsibilities (teacher_student_id, responsibility_for, title, effective_from)
SELECT ts.id, 'STUDENT', 'Attend classes regularly', '2026-01-01' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';

INSERT IGNORE INTO tmn_student_billing (teacher_student_id, billing_mode, rate, effective_from, status)
SELECT ts.id, 'HOURLY', 300.00, '2026-01-01', 'ACTIVE' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';
INSERT IGNORE INTO tmn_student_billing (teacher_student_id, billing_mode, rate, effective_from, status)
SELECT ts.id, 'FIXED_MONTHLY', 2000.00, '2026-01-01', 'ACTIVE' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.arjun';

INSERT IGNORE INTO tmn_attendance (teacher_student_id, session_date, start_time, end_time, duration_minutes, status, remarks)
SELECT ts.id, '2026-08-05', '16:00:00', '17:00:00', 60, 'PRESENT', 'Algebra revision' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';
INSERT IGNORE INTO tmn_attendance (teacher_student_id, session_date, start_time, end_time, duration_minutes, status, remarks)
SELECT ts.id, '2026-08-12', '16:00:00', '17:30:00', 90, 'PRESENT', 'Practice problems' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';

INSERT IGNORE INTO tmn_invoices (invoice_number, teacher_student_id, billing_period_from, billing_period_to, invoice_date, due_date, subtotal, discount_amount, total_amount, status)
SELECT 'TMN-2026-000001', ts.id, '2026-08-01', '2026-08-31', '2026-09-01', '2026-09-10', 3000.00, 0.00, 3000.00, 'PARTIALLY_PAID' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.kavya';
INSERT IGNORE INTO tmn_invoices (invoice_number, teacher_student_id, billing_period_from, billing_period_to, invoice_date, due_date, subtotal, discount_amount, total_amount, status)
SELECT 'TMN-2026-000002', ts.id, '2026-08-01', '2026-08-31', '2026-09-01', '2026-09-10', 2000.00, 0.00, 2000.00, 'ISSUED' FROM tmn_teacher_students ts JOIN tmn_users s ON s.id = ts.student_user_id WHERE s.username = 'student.arjun';

INSERT IGNORE INTO tmn_invoice_items (invoice_id, description, quantity, unit_rate, amount, sort_order)
SELECT id, 'Tuition — 10 hours', 10.00, 300.00, 3000.00, 1 FROM tmn_invoices WHERE invoice_number = 'TMN-2026-000001';
INSERT IGNORE INTO tmn_invoice_items (invoice_id, description, quantity, unit_rate, amount, sort_order)
SELECT id, 'Monthly tuition fee', 1.00, 2000.00, 2000.00, 1 FROM tmn_invoices WHERE invoice_number = 'TMN-2026-000002';

INSERT IGNORE INTO tmn_payments (invoice_id, payment_date, amount, payment_method, reference_number, remarks)
SELECT id, '2026-09-03', 1500.00, 'UPI', 'DEMO-UPI-001', 'Development-only sample payment' FROM tmn_invoices WHERE invoice_number = 'TMN-2026-000001';

INSERT IGNORE INTO tmn_invoice_sequences (sequence_scope, current_value) VALUES ('GLOBAL', 2);
INSERT IGNORE INTO tmn_system_settings (setting_key, setting_value) VALUES ('application_name', 'Tuman'), ('default_currency', 'INR');
