-- Run only after confirming the duplicate-pair precheck returns no rows.
SELECT teacher_user_id, student_user_id, COUNT(*) AS duplicate_count
FROM tmn_teacher_students
GROUP BY teacher_user_id, student_user_id
HAVING COUNT(*) > 1;

ALTER TABLE tmn_teacher_students
    ADD CONSTRAINT uq_tmn_teacher_students_pair UNIQUE (teacher_user_id, student_user_id);
