-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 09, 2026 at 08:52 AM
-- Server version: 10.11.19-MariaDB
-- PHP Version: 8.4.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `santakarma_tuman`
--

-- --------------------------------------------------------

--
-- Table structure for table `tmn_activity_log`
--

CREATE TABLE `tmn_activity_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `actor_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `details_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details_json`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_activity_log`
--

INSERT INTO `tmn_activity_log` (`id`, `actor_user_id`, `action`, `entity_type`, `entity_id`, `details_json`, `created_at`) VALUES
(4, 1, 'USER_STATUS_CHANGED', 'USER', 4, '{\"to\": \"INACTIVE\", \"from\": \"ACTIVE\"}', '2026-09-02 11:31:30'),
(5, 1, 'USER_STATUS_CHANGED', 'USER', 4, '{\"to\": \"ACTIVE\", \"from\": \"INACTIVE\"}', '2026-09-02 11:31:30'),
(39, 2, 'INVOICE_CREATED', 'INVOICE', 7, '{\"status\": \"DRAFT\", \"assignment_id\": 2, \"billing_month\": \"2026-09\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000003\"}', '2026-09-02 19:42:04'),
(40, 1, 'USER_CREATED', 'USER', 12, '{\"role\": \"STUDENT\", \"username\": \"admin.santanu\"}', '2026-09-03 09:41:10'),
(41, 1, 'USER_UPDATED', 'USER', 12, '{\"username\": \"admin.santanu\"}', '2026-09-03 09:41:47'),
(42, 1, 'USER_ROLE_CHANGED', 'USER', 12, '{\"to\": \"ADMIN\", \"from\": \"STUDENT\"}', '2026-09-03 09:41:47'),
(43, 1, 'USER_CREATED', 'USER', 14, '{\"role\": \"TEACHER\", \"username\": \"teacher.santanu\"}', '2026-09-03 09:45:05'),
(44, 14, 'STUDENT_LINKED', 'TEACHER_STUDENT', 6, '{\"student_id\": 4}', '2026-09-03 10:25:55'),
(45, 14, 'STUDENT_LINKED', 'TEACHER_STUDENT', 7, '{\"student_id\": 5}', '2026-09-03 10:29:37'),
(46, 14, 'PROFILE_UPDATED', 'USER', 14, '[]', '2026-09-03 11:58:36'),
(47, 14, 'PROFILE_UPDATED', 'USER', 14, '[]', '2026-09-03 11:58:56'),
(48, 4, 'PROFILE_UPDATED', 'USER', 4, '[]', '2026-09-03 12:04:28'),
(49, 4, 'PROFILE_UPDATED', 'USER', 4, '[]', '2026-09-03 12:04:40'),
(50, 2, 'INVOICE_DISCOUNT_UPDATED', 'INVOICE', 7, '{\"currency_code\": \"INR\", \"discount_amount\": \"200.00\"}', '2026-09-03 12:40:55'),
(51, 2, 'INVOICE_ISSUED', 'INVOICE', 7, '{\"to\": \"ISSUED\", \"invoice_number\": \"TMN-2026-000003\"}', '2026-09-03 12:41:11'),
(52, 2, 'INVOICE_CREATED', 'INVOICE', 8, '{\"status\": \"DRAFT\", \"assignment_id\": 2, \"billing_month\": \"2026-03\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000004\"}', '2026-09-03 12:45:53'),
(53, 2, 'INVOICE_CANCELLED', 'INVOICE', 8, '{\"to\": \"CANCELLED\", \"invoice_number\": \"TMN-2026-000004\"}', '2026-09-03 12:46:41'),
(54, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 7, '{\"status\": \"PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000003\"}', '2026-09-03 15:30:15'),
(55, 2, 'OVERPAYMENT_CREDIT_CREATED', 'STUDENT_CREDIT', 1, '{\"amount\": \"700.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000003\"}', '2026-09-03 15:30:15'),
(56, 2, 'PAYMENT_RECORDED', 'PAYMENT', 2, '{\"amount\": \"2500.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000003\", \"invoice_status\": \"PAID\", \"payment_method\": \"CASH\"}', '2026-09-03 15:30:15'),
(57, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 2, '{\"status\": \"PARTIALLY_PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000002\"}', '2026-09-03 15:31:59'),
(58, 2, 'CREDIT_APPLIED', 'STUDENT_CREDIT', 1, '{\"amount\": \"700.00\", \"invoice_id\": 2, \"currency_code\": \"INR\"}', '2026-09-03 15:31:59'),
(59, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 2, '{\"status\": \"PARTIALLY_PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000002\"}', '2026-09-03 15:33:37'),
(60, 2, 'PAYMENT_RECORDED', 'PAYMENT', 3, '{\"amount\": \"1300.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000002\", \"invoice_status\": \"PARTIALLY_PAID\", \"payment_method\": \"CASH\"}', '2026-09-03 15:33:37'),
(61, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 2, '{\"status\": \"PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000002\"}', '2026-09-03 15:39:16'),
(62, 2, 'INVOICE_CREATED', 'INVOICE', 9, '{\"status\": \"DRAFT\", \"assignment_id\": 2, \"billing_month\": \"2026-04\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000005\"}', '2026-09-03 15:48:48'),
(63, 2, 'INVOICE_ISSUED', 'INVOICE', 9, '{\"to\": \"ISSUED\", \"invoice_number\": \"TMN-2026-000005\"}', '2026-09-03 15:52:02'),
(64, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 9, '{\"status\": \"PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000005\"}', '2026-09-03 15:58:13'),
(65, 2, 'OVERPAYMENT_CREDIT_CREATED', 'STUDENT_CREDIT', 2, '{\"amount\": \"500.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000005\"}', '2026-09-03 15:58:13'),
(66, 2, 'PAYMENT_RECORDED', 'PAYMENT', 4, '{\"amount\": \"2500.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000005\", \"invoice_status\": \"PAID\", \"payment_method\": \"CASH\"}', '2026-09-03 15:58:13'),
(67, 2, 'INVOICE_CREATED', 'INVOICE', 10, '{\"status\": \"DRAFT\", \"assignment_id\": 2, \"billing_month\": \"2026-05\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000006\"}', '2026-09-03 15:59:10'),
(68, 2, 'INVOICE_ISSUED', 'INVOICE', 10, '{\"to\": \"ISSUED\", \"invoice_number\": \"TMN-2026-000006\"}', '2026-09-03 15:59:28'),
(69, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 10, '{\"status\": \"PARTIALLY_PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000006\"}', '2026-09-03 16:00:46'),
(70, 2, 'CREDIT_APPLIED', 'STUDENT_CREDIT', 2, '{\"amount\": \"500.00\", \"invoice_id\": 10, \"currency_code\": \"INR\"}', '2026-09-03 16:00:46'),
(71, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 10, '{\"status\": \"PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000006\"}', '2026-09-03 16:07:17'),
(72, 2, 'PAYMENT_RECORDED', 'PAYMENT', 5, '{\"amount\": \"1500.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000006\", \"invoice_status\": \"PAID\", \"payment_method\": \"CASH\"}', '2026-09-03 16:07:17'),
(73, 2, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 7, '{\"billing_mode\": \"HOURLY\", \"currency_code\": \"INR\"}', '2026-09-03 20:12:23'),
(74, 2, 'ATTENDANCE_CREATED', 'ATTENDANCE', 10, '{\"status\": \"PRESENT\", \"assignment_id\": 2}', '2026-09-03 20:17:53'),
(75, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 1, '{\"status\": \"PAID\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000001\"}', '2026-09-03 20:32:02'),
(76, 2, 'OVERPAYMENT_CREDIT_CREATED', 'STUDENT_CREDIT', 3, '{\"amount\": \"3000.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000001\"}', '2026-09-03 20:32:02'),
(77, 2, 'PAYMENT_RECORDED', 'PAYMENT', 6, '{\"amount\": \"4500.00\", \"currency_code\": \"INR\", \"invoice_number\": \"TMN-2026-000001\", \"invoice_status\": \"PAID\", \"payment_method\": \"CASH\"}', '2026-09-03 20:32:02'),
(78, 2, 'ADJUSTMENT_REFUND_RECORDED', 'REFUND', 1, '{\"amount\": \"500.00\", \"reason\": \"Arbitrari\", \"currency_code\": \"INR\"}', '2026-09-03 20:43:36'),
(79, 2, 'CREDIT_REFUNDED', 'REFUND', 2, '{\"amount\": \"3000.00\", \"reason\": \"Extra payment refunded\", \"credit_id\": 3, \"currency_code\": \"INR\"}', '2026-09-03 20:45:57'),
(83, 2, 'BATCH_CREATED', 'BATCH', 2, '{\"billing_mode\": \"FIXED_MONTHLY\", \"currency_code\": \"INR\"}', '2026-09-05 08:45:51'),
(84, 2, 'BATCH_MEMBER_ADDED', 'BATCH', 2, '{\"assignment_id\": 2}', '2026-09-05 08:46:41'),
(91, 2, 'BATCH_BILLING_RULE_CREATED', 'BATCH', 2, '{\"billing_mode\": \"INSTALLMENTS\"}', '2026-09-05 09:05:15'),
(92, 2, 'BATCH_BILLING_RULE_CREATED', 'BATCH', 2, '{\"rule_code\": \"INST-1\", \"billing_mode\": \"INSTALLMENTS\"}', '2026-09-05 09:12:32'),
(93, 2, 'BATCH_INVOICE_CREATED', 'INVOICE', 11, '{\"batch_id\": 2, \"rule_code\": \"INST-1\"}', '2026-09-05 09:40:41'),
(94, 2, 'INVOICE_ISSUED', 'INVOICE', 11, '{\"to\": \"ISSUED\", \"invoice_number\": \"TMN-2026-000007\"}', '2026-09-05 09:41:09'),
(95, 2, 'PROFILE_UPDATED', 'USER', 2, '[]', '2026-09-05 18:42:32'),
(96, 5, 'PROFILE_UPDATED', 'USER', 5, '[]', '2026-09-05 18:47:42'),
(97, 5, 'PROFILE_UPDATED', 'USER', 5, '[]', '2026-09-05 18:47:52'),
(98, 12, 'maintenance_backup_failed', 'BACKUP_RUN', 1, '[]', '2026-09-05 22:12:21'),
(99, 12, 'maintenance_backup_succeeded', 'BACKUP_RUN', 6, '{\"identifier\": \"tuman-20260905-164453-887100e61634.sql.gz\", \"size_bytes\": 8602}', '2026-09-05 22:14:53'),
(100, 5, 'PROFILE_UPDATED', 'USER', 5, '[]', '2026-09-06 09:50:15'),
(101, 2, 'PROFILE_UPDATED', 'USER', 2, '[]', '2026-09-06 10:19:21'),
(102, 2, 'MESSAGE_SENT', 'MESSAGE', 1, '{\"category\": \"ANNOUNCEMENT\", \"recipient_count\": 1}', '2026-09-06 10:20:07'),
(103, 2, 'EMAIL_QUEUED', 'MESSAGE', 1, '[]', '2026-09-06 10:20:07'),
(105, 2, 'MESSAGE_SENT', 'MESSAGE', 2, '{\"category\": \"ANNOUNCEMENT\", \"recipient_count\": 1}', '2026-09-06 10:25:03'),
(106, 2, 'EMAIL_QUEUED', 'MESSAGE', 2, '[]', '2026-09-06 10:25:03'),
(107, 5, 'MESSAGE_SENT', 'MESSAGE', 3, '{\"category\": \"OFFICIAL\", \"recipient_count\": 1}', '2026-09-06 10:26:34'),
(108, 5, 'EMAIL_QUEUED', 'MESSAGE', 3, '[]', '2026-09-06 10:26:34'),
(109, 5, 'MESSAGE_SENT', 'MESSAGE', 4, '{\"category\": \"OFFICIAL\", \"recipient_count\": 1}', '2026-09-06 10:30:27'),
(110, 5, 'EMAIL_QUEUED', 'MESSAGE', 4, '[]', '2026-09-06 10:30:27'),
(111, 1, 'USER_PASSWORD_RESET', 'USER', 12, '[]', '2026-09-07 11:54:21'),
(112, 12, 'USER_PASSWORD_RESET', 'USER', 14, '[]', '2026-09-07 11:57:59'),
(113, 2, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 8, '{\"student_id\":15}', '2026-09-07 12:44:08'),
(114, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 9, '{\"student_id\":16}', '2026-09-07 14:48:40'),
(115, 14, 'TEACHER_STUDENT_STATUS_CHANGED', 'TEACHER_STUDENT', 7, '{\"to\":\"INACTIVE\"}', '2026-09-07 14:49:01'),
(116, 14, 'TEACHER_STUDENT_STATUS_CHANGED', 'TEACHER_STUDENT', 6, '{\"to\":\"INACTIVE\"}', '2026-09-07 14:49:11'),
(117, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 10, '{\"student_id\":17}', '2026-09-07 14:51:00'),
(118, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 11, '{\"student_id\":18}', '2026-09-07 14:52:46'),
(119, 14, 'BATCH_CREATED', 'BATCH', 5, '{\"billing_mode\":\"INSTALLMENTS\",\"currency_code\":\"INR\"}', '2026-09-07 14:57:54'),
(120, 14, 'BATCH_BILLING_RULE_CREATED', 'BATCH', 5, '{\"billing_mode\":\"INSTALLMENTS\",\"rule_code\":\"INITIAL-INSTALLMENTS\"}', '2026-09-07 14:57:54'),
(121, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 5, '{\"assignment_id\":10}', '2026-09-07 14:59:13'),
(122, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 5, '{\"assignment_id\":11}', '2026-09-07 14:59:22'),
(123, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 12, '{\"student_id\":19}', '2026-09-07 15:18:14'),
(124, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 8, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 15:19:41'),
(125, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 9, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 15:20:46'),
(126, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 10, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 15:21:57'),
(127, 2, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 11, '{\"invoice_number\":\"TMN-2026-000007\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-07 17:00:09'),
(128, 2, 'PAYMENT_RECORDED', 'PAYMENT', 7, '{\"invoice_number\":\"TMN-2026-000007\",\"payment_method\":\"CASH\",\"amount\":\"500.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-07 17:00:09'),
(129, 2, 'INVOICE_CREATED', 'INVOICE', 12, '{\"invoice_number\":\"TMN-2026-000008\",\"assignment_id\":2,\"billing_month\":\"2026-06\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-07 17:02:24'),
(130, 2, 'INVOICE_CANCELLED', 'INVOICE', 12, '{\"invoice_number\":\"TMN-2026-000008\",\"to\":\"CANCELLED\"}', '2026-09-07 17:02:53'),
(131, 12, 'maintenance_backup_failed', 'BACKUP_RUN', 11, '[]', '2026-09-07 17:23:09'),
(132, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 13, '{\"student_id\":20}', '2026-09-07 18:21:24'),
(133, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 14, '{\"student_id\":21}', '2026-09-07 18:23:11'),
(134, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 15, '{\"student_id\":22}', '2026-09-07 18:24:23'),
(135, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 16, '{\"student_id\":23}', '2026-09-07 18:25:35'),
(136, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 15, '{\"country_changed\":true}', '2026-09-07 18:26:38'),
(137, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 14, '{\"country_changed\":true}', '2026-09-07 18:27:01'),
(138, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 13, '{\"country_changed\":true}', '2026-09-07 18:27:23'),
(139, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 17, '{\"student_id\":24}', '2026-09-07 18:28:51'),
(140, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 18, '{\"student_id\":25}', '2026-09-07 18:29:58'),
(141, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 18, '{\"country_changed\":true}', '2026-09-07 18:30:29'),
(142, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 19, '{\"student_id\":26}', '2026-09-07 18:31:43'),
(143, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 20, '{\"student_id\":27}', '2026-09-07 18:32:59'),
(144, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 20, '{\"country_changed\":false}', '2026-09-07 18:34:03'),
(145, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 21, '{\"student_id\":28}', '2026-09-07 18:35:43'),
(146, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 22, '{\"student_id\":29}', '2026-09-07 18:38:32'),
(147, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 22, '{\"country_changed\":true}', '2026-09-07 18:39:00'),
(148, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 23, '{\"student_id\":30}', '2026-09-07 18:40:17'),
(149, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 24, '{\"student_id\":31}', '2026-09-07 18:43:15'),
(150, 14, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 25, '{\"student_id\":32}', '2026-09-07 18:52:28'),
(151, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 11, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:07:30'),
(152, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 12, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:09:20'),
(153, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 13, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:10:35'),
(154, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 14, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:12:48'),
(155, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 15, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:14:03'),
(156, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 16, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:15:25'),
(157, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 17, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:16:15'),
(158, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 18, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:17:28'),
(159, 14, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 19, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:18:43'),
(160, 14, 'BATCH_CREATED', 'BATCH', 6, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:23:33'),
(161, 14, 'BATCH_BILLING_RULE_CREATED', 'BATCH', 6, '{\"billing_mode\":\"FIXED_MONTHLY\",\"rule_code\":\"INITIAL-FIXED-MONTHLY\"}', '2026-09-07 20:23:33'),
(162, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 6, '{\"assignment_id\":13}', '2026-09-07 20:24:10'),
(163, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 6, '{\"assignment_id\":14}', '2026-09-07 20:24:29'),
(164, 14, 'BATCH_CREATED', 'BATCH', 7, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-07 20:28:18'),
(165, 14, 'BATCH_BILLING_RULE_CREATED', 'BATCH', 7, '{\"billing_mode\":\"FIXED_MONTHLY\",\"rule_code\":\"INITIAL-FIXED-MONTHLY\"}', '2026-09-07 20:28:18'),
(166, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 7, '{\"assignment_id\":15}', '2026-09-07 20:28:43'),
(167, 14, 'BATCH_MEMBER_ADDED', 'BATCH', 7, '{\"assignment_id\":16}', '2026-09-07 20:29:05'),
(168, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 22, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:36:58'),
(169, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 20, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:37:25'),
(170, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 9, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:37:56'),
(171, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 19, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:38:27'),
(172, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 14, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:38:53'),
(173, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 12, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:40:19'),
(174, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 10, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:40:38'),
(175, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 23, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:40:59'),
(176, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 13, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:41:29'),
(177, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 25, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:41:50'),
(178, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 17, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:42:24'),
(179, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 18, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:42:41'),
(180, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 11, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:43:09'),
(181, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 21, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:43:52'),
(182, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 15, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:44:09'),
(183, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 16, '{\"country_changed\":false,\"effective_from\":\"2026-09-01\",\"status\":\"ACTIVE\"}', '2026-09-08 08:44:37'),
(184, 2, 'PROFILE_UPDATED', 'USER', 2, '[]', '2026-09-08 10:17:57'),
(185, 12, 'USER_CREATED', 'USER', 33, '{\"username\":\"teacher.mita.karmakar\",\"role\":\"TEACHER\"}', '2026-09-08 10:20:03'),
(186, 33, 'STUDENT_ENROLLED', 'TEACHER_STUDENT', 26, '{\"student_id\":34,\"effective_from\":\"2026-09-01\"}', '2026-09-08 10:23:16'),
(187, 33, 'BILLING_RULE_CREATED', 'STUDENT_BILLING', 20, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-08 10:24:57'),
(188, 33, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 20, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-08 10:25:18'),
(189, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 21, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-08 12:21:20'),
(190, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 19, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-08 12:30:37'),
(191, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 13, '{\"assignment_id\":21,\"status\":\"PRESENT\"}', '2026-09-08 12:32:41'),
(192, 14, 'ADVANCE_CREDIT_RECORDED', 'STUDENT_CREDIT', 4, '{\"amount\":\"1200.00\",\"currency_code\":\"INR\",\"payment_method\":\"UPI\",\"reference_number\":\"Sandip-Adv-22-08-2026\",\"remarks\":\"Advance for next three classes\"}', '2026-09-08 17:31:13'),
(193, 14, 'BATCH_INVOICE_CREATED', 'INVOICE', 13, '{\"batch_id\":6,\"rule_code\":\"INITIAL-FIXED-MONTHLY\"}', '2026-09-08 19:39:03'),
(194, 14, 'INVOICE_ISSUED', 'INVOICE', 13, '{\"invoice_number\":\"TMN-2026-000009\",\"to\":\"ISSUED\"}', '2026-09-08 19:39:56'),
(195, 14, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 13, '{\"invoice_number\":\"TMN-2026-000009\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-08 19:42:27'),
(196, 14, 'PAYMENT_RECORDED', 'PAYMENT', 8, '{\"invoice_number\":\"TMN-2026-000009\",\"payment_method\":\"UPI\",\"amount\":\"2400.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-08 19:42:27'),
(197, 14, 'BATCH_INVOICE_CREATED', 'INVOICE', 14, '{\"batch_id\":7,\"rule_code\":\"INITIAL-FIXED-MONTHLY\"}', '2026-09-08 19:50:22'),
(198, 14, 'INVOICE_ISSUED', 'INVOICE', 14, '{\"invoice_number\":\"TMN-2026-000010\",\"to\":\"ISSUED\"}', '2026-09-08 19:50:33'),
(199, 14, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 14, '{\"invoice_number\":\"TMN-2026-000010\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-08 19:54:30'),
(200, 14, 'PAYMENT_RECORDED', 'PAYMENT', 9, '{\"invoice_number\":\"TMN-2026-000010\",\"payment_method\":\"UPI\",\"amount\":\"2000.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-08 19:54:30'),
(201, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 9, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 06:45:29'),
(202, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 25, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 06:46:14'),
(203, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 15, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-09 06:48:34'),
(204, 14, 'INVOICE_CREATED', 'INVOICE', 15, '{\"invoice_number\":\"TMN-2026-000011\",\"assignment_id\":25,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 06:49:21'),
(205, 14, 'INVOICE_ISSUED', 'INVOICE', 15, '{\"invoice_number\":\"TMN-2026-000011\",\"to\":\"ISSUED\"}', '2026-09-09 06:49:30'),
(206, 14, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 15, '{\"invoice_number\":\"TMN-2026-000011\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-09 06:53:56'),
(207, 14, 'PAYMENT_RECORDED', 'PAYMENT', 10, '{\"invoice_number\":\"TMN-2026-000011\",\"payment_method\":\"UPI\",\"amount\":\"1200.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-09 06:53:56'),
(208, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 18, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 06:54:55'),
(209, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 11, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-09 06:55:45'),
(210, 14, 'INVOICE_CREATED', 'INVOICE', 16, '{\"invoice_number\":\"TMN-2026-000012\",\"assignment_id\":18,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 06:56:35'),
(211, 14, 'INVOICE_ISSUED', 'INVOICE', 16, '{\"invoice_number\":\"TMN-2026-000012\",\"to\":\"ISSUED\"}', '2026-09-09 06:56:47'),
(212, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 23, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 06:57:13'),
(213, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 12, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-09 06:57:47'),
(214, 14, 'INVOICE_CREATED', 'INVOICE', 17, '{\"invoice_number\":\"TMN-2026-000013\",\"assignment_id\":23,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 06:58:41'),
(215, 14, 'INVOICE_ISSUED', 'INVOICE', 17, '{\"invoice_number\":\"TMN-2026-000013\",\"to\":\"ISSUED\"}', '2026-09-09 07:00:03'),
(216, 14, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 17, '{\"invoice_number\":\"TMN-2026-000013\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-09 07:01:38'),
(217, 14, 'PAYMENT_RECORDED', 'PAYMENT', 11, '{\"invoice_number\":\"TMN-2026-000013\",\"payment_method\":\"UPI\",\"amount\":\"800.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-09 07:01:38'),
(218, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 17, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 07:02:31'),
(219, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 13, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-09 07:03:07'),
(220, 14, 'INVOICE_CREATED', 'INVOICE', 18, '{\"invoice_number\":\"TMN-2026-000014\",\"assignment_id\":17,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 07:03:43'),
(221, 14, 'INVOICE_ISSUED', 'INVOICE', 18, '{\"invoice_number\":\"TMN-2026-000014\",\"to\":\"ISSUED\"}', '2026-09-09 07:03:52'),
(222, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 22, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 07:05:54'),
(223, 14, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 20, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 07:06:30'),
(224, 14, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 9, '{\"billing_mode\":\"HOURLY\",\"currency_code\":\"INR\"}', '2026-09-09 07:07:26'),
(225, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 14, '{\"assignment_id\":9,\"status\":\"PRESENT\"}', '2026-09-09 07:10:05'),
(226, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 15, '{\"assignment_id\":9,\"status\":\"PRESENT\"}', '2026-09-09 07:11:01'),
(227, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 16, '{\"assignment_id\":9,\"status\":\"PRESENT\"}', '2026-09-09 07:11:57'),
(228, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 17, '{\"assignment_id\":9,\"status\":\"PRESENT\"}', '2026-09-09 07:13:32'),
(229, 14, 'ATTENDANCE_CREATED', 'ATTENDANCE', 18, '{\"assignment_id\":9,\"status\":\"PRESENT\"}', '2026-09-09 07:14:58'),
(230, 14, 'INVOICE_CREATED', 'INVOICE', 19, '{\"invoice_number\":\"TMN-2026-000015\",\"assignment_id\":9,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 07:41:08'),
(231, 14, 'INVOICE_ISSUED', 'INVOICE', 19, '{\"invoice_number\":\"TMN-2026-000015\",\"to\":\"ISSUED\"}', '2026-09-09 07:41:21'),
(232, 14, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 19, '{\"invoice_number\":\"TMN-2026-000015\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-09 07:44:19'),
(233, 14, 'PAYMENT_RECORDED', 'PAYMENT', 12, '{\"invoice_number\":\"TMN-2026-000015\",\"payment_method\":\"UPI\",\"amount\":\"1000.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-09 07:44:19'),
(234, 33, 'STUDENT_PROFILE_UPDATED', 'TEACHER_STUDENT', 26, '{\"country_changed\":false,\"effective_from\":\"2026-08-01\",\"status\":\"ACTIVE\"}', '2026-09-09 08:46:04'),
(235, 33, 'BILLING_RULE_UPDATED', 'STUDENT_BILLING', 20, '{\"billing_mode\":\"FIXED_MONTHLY\",\"currency_code\":\"INR\"}', '2026-09-09 08:46:33'),
(236, 33, 'INVOICE_CREATED', 'INVOICE', 20, '{\"invoice_number\":\"TMN-2026-000016\",\"assignment_id\":26,\"billing_month\":\"2026-08\",\"currency_code\":\"INR\",\"status\":\"DRAFT\"}', '2026-09-09 08:47:26'),
(237, 33, 'INVOICE_ISSUED', 'INVOICE', 20, '{\"invoice_number\":\"TMN-2026-000016\",\"to\":\"ISSUED\"}', '2026-09-09 08:47:32'),
(238, 33, 'INVOICE_PAYMENT_STATUS_CHANGED', 'INVOICE', 20, '{\"invoice_number\":\"TMN-2026-000016\",\"currency_code\":\"INR\",\"status\":\"PAID\"}', '2026-09-09 08:48:47'),
(239, 33, 'PAYMENT_RECORDED', 'PAYMENT', 13, '{\"invoice_number\":\"TMN-2026-000016\",\"payment_method\":\"UPI\",\"amount\":\"2000.00\",\"currency_code\":\"INR\",\"invoice_status\":\"PAID\"}', '2026-09-09 08:48:47');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_admin_profiles`
--

CREATE TABLE `tmn_admin_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address_line1` varchar(255) DEFAULT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state_name` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `profile_details` text DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tmn_attendance`
--

CREATE TABLE `tmn_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `billing_rule_id` bigint(20) UNSIGNED DEFAULT NULL,
  `batch_id` bigint(20) UNSIGNED DEFAULT NULL,
  `batch_billing_rule_id` bigint(20) UNSIGNED DEFAULT NULL,
  `session_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `duration_minutes` smallint(5) UNSIGNED DEFAULT NULL,
  `status` enum('PRESENT','ABSENT','LEAVE','CANCELLED','HOLIDAY') NOT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_attendance`
--

INSERT INTO `tmn_attendance` (`id`, `teacher_student_id`, `billing_rule_id`, `batch_id`, `batch_billing_rule_id`, `session_date`, `start_time`, `end_time`, `duration_minutes`, `status`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, NULL, NULL, '2026-08-05', '16:00:00', '17:00:00', 60, 'PRESENT', 'Algebra revision', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(2, 1, NULL, NULL, NULL, '2026-08-12', '16:00:00', '17:30:00', 90, 'PRESENT', 'Practice problems', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(10, 2, 7, NULL, NULL, '2026-09-03', '21:00:00', '22:00:00', 60, 'PRESENT', 'Special class', '2026-09-03 20:17:53', '2026-09-03 20:17:53'),
(13, 21, 19, NULL, NULL, '2026-08-22', '16:00:00', '17:00:00', 60, 'PRESENT', 'MS PROJECT application for handling project related works.', '2026-09-08 12:32:41', '2026-09-08 12:32:41'),
(14, 9, 9, NULL, NULL, '2026-08-18', '18:00:00', '19:00:00', 60, 'PRESENT', NULL, '2026-09-09 07:10:05', '2026-09-09 07:10:05'),
(15, 9, 9, NULL, NULL, '2026-08-21', '18:00:00', '19:00:00', 60, 'PRESENT', NULL, '2026-09-09 07:11:01', '2026-09-09 07:11:01'),
(16, 9, 9, NULL, NULL, '2026-08-25', '18:00:00', '19:00:00', 60, 'PRESENT', NULL, '2026-09-09 07:11:57', '2026-09-09 07:11:57'),
(17, 9, 9, NULL, NULL, '2026-08-28', '18:00:00', '19:00:00', 60, 'PRESENT', NULL, '2026-09-09 07:13:32', '2026-09-09 07:13:32'),
(18, 9, 9, NULL, NULL, '2026-09-01', '19:00:00', '20:00:00', 60, 'PRESENT', 'One hr Late', '2026-09-09 07:14:58', '2026-09-09 07:14:58');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_backup_runs`
--

CREATE TABLE `tmn_backup_runs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `initiated_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('RUNNING','SUCCEEDED','FAILED') NOT NULL DEFAULT 'RUNNING',
  `storage_identifier` varchar(255) DEFAULT NULL,
  `file_size_bytes` bigint(20) UNSIGNED DEFAULT NULL,
  `error_summary` varchar(500) DEFAULT NULL,
  `started_at` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_backup_runs`
--

INSERT INTO `tmn_backup_runs` (`id`, `initiated_by_user_id`, `status`, `storage_identifier`, `file_size_bytes`, `error_summary`, `started_at`, `completed_at`) VALUES
(1, 12, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-05 22:12:21', '2026-09-05 16:42:21'),
(2, NULL, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-05 22:13:25', '2026-09-05 16:43:25'),
(3, NULL, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-05 22:13:37', '2026-09-05 16:43:37'),
(4, NULL, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-05 22:13:42', '2026-09-05 16:43:42'),
(5, NULL, 'SUCCEEDED', 'tuman-20260905-164421-a5eef240ea08.sql.gz', 8552, NULL, '2026-09-05 22:14:21', '2026-09-05 16:44:21'),
(6, 12, 'SUCCEEDED', 'tuman-20260905-164453-887100e61634.sql.gz', 8602, NULL, '2026-09-05 16:44:53', '2026-09-05 16:44:53'),
(7, NULL, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-06 05:04:22', '2026-09-06 05:04:22'),
(8, NULL, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-06 05:04:46', '2026-09-06 05:04:46'),
(9, NULL, 'SUCCEEDED', 'tuman-20260906-050453-1fb08066b946.sql.gz', 9527, NULL, '2026-09-06 05:04:53', '2026-09-06 05:04:53'),
(10, 12, 'RUNNING', NULL, NULL, NULL, '2026-09-06 05:07:56', NULL),
(11, 12, 'FAILED', NULL, NULL, 'Backup did not complete. Check the server log and configuration.', '2026-09-07 11:53:09', '2026-09-07 11:53:09');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_batches`
--

CREATE TABLE `tmn_batches` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_user_id` bigint(20) UNSIGNED NOT NULL,
  `batch_name` varchar(150) NOT NULL,
  `objective` text DEFAULT NULL,
  `teacher_responsibility` text DEFAULT NULL,
  `student_responsibility` text DEFAULT NULL,
  `batch_terms` text DEFAULT NULL,
  `billing_mode` enum('FIXED_MONTHLY','INSTALLMENTS','ONETIME') NOT NULL,
  `charge` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'INR',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_batches`
--

INSERT INTO `tmn_batches` (`id`, `teacher_user_id`, `batch_name`, `objective`, `teacher_responsibility`, `student_responsibility`, `batch_terms`, `billing_mode`, `charge`, `currency_code`, `status`, `created_at`, `updated_at`) VALUES
(2, 2, 'Batch 1', 'Teaching Python', 'Teacher should conduct regular classes', 'Student should attend classes', 'REgular attendence is required', 'FIXED_MONTHLY', 3000.00, 'INR', 'ACTIVE', '2026-09-05 08:45:51', '2026-09-05 08:45:51'),
(5, 14, 'Sound&Music1', 'To learn about AI based music creation and songwriting', 'To get the students learn the skills practically', '1) Follow instructions diligently \r\n2) To do the practicall assignments regularly', 'Initial four classes will be charged 1200/- \r\nRest will be charged as required on a daily terms', 'INSTALLMENTS', 1200.00, 'INR', 'ACTIVE', '2026-09-07 14:57:54', '2026-09-07 14:57:54'),
(6, 14, 'AI-Debayudh-Antarip', 'AI Related Discussions', 'Teach subjects relevant to Artificial Intelligence', 'Follow advices', 'Every month advance - 2400', 'FIXED_MONTHLY', 2400.00, 'INR', 'ACTIVE', '2026-09-07 20:23:33', '2026-09-07 20:23:33'),
(7, 14, 'AI-Srinjini-Srinjoy', 'Learning AI related subjects', 'Teaching AI specific subjects and projects', 'Follow instructions', 'Advance payment - 2000 monthly', 'FIXED_MONTHLY', 2000.00, 'INR', 'ACTIVE', '2026-09-07 20:28:18', '2026-09-07 20:28:18');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_batch_billing_rules`
--

CREATE TABLE `tmn_batch_billing_rules` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `batch_id` bigint(20) UNSIGNED NOT NULL,
  `rule_code` varchar(50) NOT NULL,
  `rule_name` varchar(100) NOT NULL,
  `billing_mode` enum('FIXED_MONTHLY','INSTALLMENTS','ONETIME') NOT NULL,
  `charge` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'INR',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_batch_billing_rules`
--

INSERT INTO `tmn_batch_billing_rules` (`id`, `batch_id`, `rule_code`, `rule_name`, `billing_mode`, `charge`, `currency_code`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 'RULE-1', 'Monthly rule 1', 'FIXED_MONTHLY', 3000.00, 'INR', 'ACTIVE', '2026-09-05 08:58:20', '2026-09-05 09:10:06'),
(3, 2, 'RULE-3', 'Instalment rule 3', 'INSTALLMENTS', 400.00, 'INR', 'ACTIVE', '2026-09-05 09:05:15', '2026-09-05 09:10:06'),
(5, 2, 'INST-1', 'First instalment', 'INSTALLMENTS', 500.00, 'INR', 'ACTIVE', '2026-09-05 09:12:32', '2026-09-05 09:12:32'),
(6, 5, 'INITIAL-INSTALLMENTS', 'Installments tuition', 'INSTALLMENTS', 1200.00, 'INR', 'ACTIVE', '2026-09-07 14:57:54', '2026-09-07 14:57:54'),
(7, 6, 'INITIAL-FIXED-MONTHLY', 'Fixed Monthly tuition', 'FIXED_MONTHLY', 2400.00, 'INR', 'ACTIVE', '2026-09-07 20:23:33', '2026-09-07 20:23:33'),
(8, 7, 'INITIAL-FIXED-MONTHLY', 'Fixed Monthly tuition', 'FIXED_MONTHLY', 2000.00, 'INR', 'ACTIVE', '2026-09-07 20:28:18', '2026-09-07 20:28:18');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_batch_students`
--

CREATE TABLE `tmn_batch_students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `batch_id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `enrolled_on` date NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_batch_students`
--

INSERT INTO `tmn_batch_students` (`id`, `batch_id`, `teacher_student_id`, `enrolled_on`, `status`, `created_at`, `updated_at`) VALUES
(2, 2, 2, '2026-09-05', 'ACTIVE', '2026-09-05 08:46:41', '2026-09-05 08:46:41'),
(5, 5, 10, '2026-09-07', 'ACTIVE', '2026-09-07 14:59:13', '2026-09-07 14:59:13'),
(6, 5, 11, '2026-09-07', 'ACTIVE', '2026-09-07 14:59:22', '2026-09-07 14:59:22'),
(7, 6, 13, '2026-09-07', 'ACTIVE', '2026-09-07 20:24:10', '2026-09-07 20:24:10'),
(8, 6, 14, '2026-09-07', 'ACTIVE', '2026-09-07 20:24:29', '2026-09-07 20:24:29'),
(9, 7, 15, '2026-09-07', 'ACTIVE', '2026-09-07 20:28:43', '2026-09-07 20:28:43'),
(10, 7, 16, '2026-09-07', 'ACTIVE', '2026-09-07 20:29:05', '2026-09-07 20:29:05');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_credit_applications`
--

CREATE TABLE `tmn_credit_applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `credit_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `applied_at` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `tmn_credit_applications`
--

INSERT INTO `tmn_credit_applications` (`id`, `credit_id`, `invoice_id`, `amount`, `applied_at`) VALUES
(1, 1, 2, 700.00, '2026-09-03 15:31:59'),
(2, 2, 10, 500.00, '2026-09-03 16:00:46');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_credit_refunds`
--

CREATE TABLE `tmn_credit_refunds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `credit_id` bigint(20) UNSIGNED NOT NULL,
  `refund_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `refund_method` enum('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tmn_email_log`
--

CREATE TABLE `tmn_email_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `related_entity_type` varchar(50) DEFAULT NULL,
  `related_entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient_email` varchar(254) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `delivery_status` enum('PENDING','SENT','FAILED') NOT NULL DEFAULT 'PENDING',
  `attempted_at` datetime DEFAULT NULL,
  `provider_response` varchar(1000) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_email_log`
--

INSERT INTO `tmn_email_log` (`id`, `related_entity_type`, `related_entity_id`, `recipient_email`, `subject`, `delivery_status`, `attempted_at`, `provider_response`, `created_at`) VALUES
(1, 'MESSAGE', 1, 'sann8nplayground@gmail.com', '[Announcement] Announcement', 'PENDING', NULL, NULL, '2026-09-06 10:20:07'),
(3, 'MESSAGE', 2, 'sann8nplayground@gmail.com', '[Announcement] Holiday Announcement', 'SENT', '2026-09-06 04:55:07', 'Delivered through SMTP.', '2026-09-06 10:25:03'),
(4, 'MESSAGE', 3, 'mitaksept@gmail.com', '[Official] This is a test', 'SENT', '2026-09-06 04:56:39', 'Delivered through SMTP.', '2026-09-06 10:26:34'),
(5, 'MESSAGE', 4, 'mitaksept@gmail.com', '[Official] Testing again', 'SENT', '2026-09-06 05:00:31', 'Delivered through SMTP.', '2026-09-06 10:30:27');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_invoices`
--

CREATE TABLE `tmn_invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `batch_id` bigint(20) UNSIGNED DEFAULT NULL,
  `batch_billing_rule_id` bigint(20) UNSIGNED DEFAULT NULL,
  `billing_period_from` date NOT NULL,
  `billing_period_to` date NOT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'INR',
  `special_reason` enum('ADDITIONAL_CHARGES','COMPENSATION','OTHER') DEFAULT NULL,
  `special_comment` varchar(500) DEFAULT NULL,
  `status` enum('DRAFT','ISSUED','PARTIALLY_PAID','PAID','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_invoices`
--

INSERT INTO `tmn_invoices` (`id`, `invoice_number`, `teacher_student_id`, `batch_id`, `batch_billing_rule_id`, `billing_period_from`, `billing_period_to`, `invoice_date`, `due_date`, `subtotal`, `discount_amount`, `total_amount`, `currency_code`, `special_reason`, `special_comment`, `status`, `created_at`, `updated_at`) VALUES
(1, 'TMN-2026-000001', 1, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', '2026-09-10', 3000.00, 0.00, 3000.00, 'INR', NULL, NULL, 'PAID', '2026-09-02 11:21:51', '2026-09-03 20:32:02'),
(2, 'TMN-2026-000002', 2, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', '2026-09-10', 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'PAID', '2026-09-02 11:21:51', '2026-09-03 15:39:16'),
(7, 'TMN-2026-000003', 2, NULL, NULL, '2026-09-01', '2026-09-30', '2026-09-02', NULL, 2000.00, 200.00, 1800.00, 'INR', NULL, NULL, 'PAID', '2026-09-02 19:42:04', '2026-09-03 15:30:15'),
(8, 'TMN-2026-000004', 2, NULL, NULL, '2026-03-01', '2026-03-31', '2026-09-03', '2026-09-10', 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'CANCELLED', '2026-09-03 12:45:53', '2026-09-03 12:46:41'),
(9, 'TMN-2026-000005', 2, NULL, NULL, '2026-04-01', '2026-04-30', '2026-09-03', '2026-09-10', 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'PAID', '2026-09-03 15:48:48', '2026-09-03 15:58:13'),
(10, 'TMN-2026-000006', 2, NULL, NULL, '2026-05-01', '2026-05-31', '2026-09-03', NULL, 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'PAID', '2026-09-03 15:59:10', '2026-09-03 16:07:17'),
(11, 'TMN-2026-000007', 2, 2, 5, '2026-09-01', '2026-09-30', '2026-09-05', NULL, 500.00, 0.00, 500.00, 'INR', NULL, NULL, 'PAID', '2026-09-05 09:40:41', '2026-09-07 17:00:09'),
(12, 'TMN-2026-000008', 2, NULL, NULL, '2026-06-01', '2026-06-30', '2026-09-07', NULL, 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'CANCELLED', '2026-09-07 17:02:24', '2026-09-07 17:02:53'),
(13, 'TMN-2026-000009', 13, 6, 7, '2026-09-01', '2026-09-30', '2026-09-01', NULL, 2400.00, 0.00, 2400.00, 'INR', NULL, NULL, 'PAID', '2026-09-08 19:39:03', '2026-09-08 19:42:27'),
(14, 'TMN-2026-000010', 15, 7, 8, '2026-09-01', '2026-09-30', '2026-09-01', NULL, 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'PAID', '2026-09-08 19:50:22', '2026-09-08 19:54:30'),
(15, 'TMN-2026-000011', 25, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', NULL, 1200.00, 0.00, 1200.00, 'INR', NULL, NULL, 'PAID', '2026-09-09 06:49:21', '2026-09-09 06:53:56'),
(16, 'TMN-2026-000012', 18, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', NULL, 1000.00, 0.00, 1000.00, 'INR', NULL, NULL, 'ISSUED', '2026-09-09 06:56:35', '2026-09-09 06:56:47'),
(17, 'TMN-2026-000013', 23, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', NULL, 800.00, 0.00, 800.00, 'INR', NULL, NULL, 'PAID', '2026-09-09 06:58:41', '2026-09-09 07:01:38'),
(18, 'TMN-2026-000014', 17, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-02', NULL, 1000.00, 0.00, 1000.00, 'INR', NULL, NULL, 'ISSUED', '2026-09-09 07:03:43', '2026-09-09 07:03:52'),
(19, 'TMN-2026-000015', 9, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', NULL, 1000.00, 0.00, 1000.00, 'INR', NULL, NULL, 'PAID', '2026-09-09 07:41:08', '2026-09-09 07:44:19'),
(20, 'TMN-2026-000016', 26, NULL, NULL, '2026-08-01', '2026-08-31', '2026-09-01', NULL, 2000.00, 0.00, 2000.00, 'INR', NULL, NULL, 'PAID', '2026-09-09 08:47:26', '2026-09-09 08:48:47');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_invoice_items`
--

CREATE TABLE `tmn_invoice_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit_rate` decimal(12,2) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `tmn_invoice_items`
--

INSERT INTO `tmn_invoice_items` (`id`, `invoice_id`, `description`, `quantity`, `unit_rate`, `amount`, `sort_order`, `created_at`) VALUES
(1, 1, 'Tuition — 10 hours', 10.00, 300.00, 3000.00, 1, '2026-09-02 11:21:51'),
(2, 2, 'Monthly tuition fee', 1.00, 2000.00, 2000.00, 1, '2026-09-02 11:21:51'),
(8, 7, 'Monthly tuition — September 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-02 19:42:04'),
(9, 8, 'Monthly tuition — March 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-03 12:45:53'),
(10, 9, 'Monthly tuition — April 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-03 15:48:48'),
(11, 10, 'Monthly tuition — May 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-03 15:59:10'),
(12, 11, 'First instalment (INST-1) — Batch 1 — 2026-09', 1.00, 500.00, 500.00, 1, '2026-09-05 09:40:41'),
(13, 12, 'Monthly tuition — June 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-07 17:02:24'),
(14, 13, 'Fixed Monthly tuition (INITIAL-FIXED-MONTHLY) — AI-Debayudh-Antarip — 2026-09', 1.00, 2400.00, 2400.00, 1, '2026-09-08 19:39:03'),
(15, 14, 'Fixed Monthly tuition (INITIAL-FIXED-MONTHLY) — AI-Srinjini-Srinjoy — 2026-09', 1.00, 2000.00, 2000.00, 1, '2026-09-08 19:50:22'),
(16, 15, 'Monthly tuition — August 2026', 1.00, 1200.00, 1200.00, 1, '2026-09-09 06:49:21'),
(17, 16, 'Monthly tuition — August 2026', 1.00, 1000.00, 1000.00, 1, '2026-09-09 06:56:35'),
(18, 17, 'Monthly tuition — August 2026', 1.00, 800.00, 800.00, 1, '2026-09-09 06:58:41'),
(19, 18, 'Monthly tuition — August 2026', 1.00, 1000.00, 1000.00, 1, '2026-09-09 07:03:43'),
(20, 19, 'Hourly tuition — Barid-250 — 2026-08-18, 18:00–19:00', 1.00, 250.00, 250.00, 1, '2026-09-09 07:41:08'),
(21, 19, 'Hourly tuition — Barid-250 — 2026-08-21, 18:00–19:00', 1.00, 250.00, 250.00, 2, '2026-09-09 07:41:08'),
(22, 19, 'Hourly tuition — Barid-250 — 2026-08-25, 18:00–19:00', 1.00, 250.00, 250.00, 3, '2026-09-09 07:41:08'),
(23, 19, 'Hourly tuition — Barid-250 — 2026-08-28, 18:00–19:00', 1.00, 250.00, 250.00, 4, '2026-09-09 07:41:08'),
(24, 20, 'Monthly tuition — August 2026', 1.00, 2000.00, 2000.00, 1, '2026-09-09 08:47:26');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_invoice_sequences`
--

CREATE TABLE `tmn_invoice_sequences` (
  `sequence_scope` varchar(30) NOT NULL,
  `current_value` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_invoice_sequences`
--

INSERT INTO `tmn_invoice_sequences` (`sequence_scope`, `current_value`, `updated_at`) VALUES
('GLOBAL', 16, '2026-09-09 08:47:26');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_messages`
--

CREATE TABLE `tmn_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_user_id` bigint(20) UNSIGNED NOT NULL,
  `category` enum('ANNOUNCEMENT','REMINDER','WARNING','URGENT_ACTION','OFFICIAL') NOT NULL DEFAULT 'OFFICIAL',
  `subject` varchar(255) NOT NULL,
  `message_body` mediumtext NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL,
  `attachment_name` varchar(255) DEFAULT NULL,
  `attachment_mime` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_messages`
--

INSERT INTO `tmn_messages` (`id`, `sender_user_id`, `category`, `subject`, `message_body`, `attachment_path`, `attachment_name`, `attachment_mime`, `created_at`) VALUES
(1, 2, 'ANNOUNCEMENT', 'Announcement', 'Tommorrow is a holiday', NULL, NULL, NULL, '2026-09-06 10:20:07'),
(2, 2, 'ANNOUNCEMENT', 'Holiday Announcement', 'Tommorrow is a holiday', NULL, NULL, NULL, '2026-09-06 10:25:03'),
(3, 5, 'OFFICIAL', 'This is a test', 'Just sending message', NULL, NULL, NULL, '2026-09-06 10:26:34'),
(4, 5, 'OFFICIAL', 'Testing again', 'I amsending a test message', NULL, NULL, NULL, '2026-09-06 10:30:27');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_message_recipients`
--

CREATE TABLE `tmn_message_recipients` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `recipient_user_id` bigint(20) UNSIGNED NOT NULL,
  `email_log_id` bigint(20) UNSIGNED DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_message_recipients`
--

INSERT INTO `tmn_message_recipients` (`id`, `message_id`, `recipient_user_id`, `email_log_id`, `read_at`, `created_at`) VALUES
(1, 1, 5, NULL, '2026-09-06 04:55:59', '2026-09-06 10:20:07'),
(2, 2, 5, 3, '2026-09-06 04:55:53', '2026-09-06 10:25:03'),
(3, 3, 2, 4, '2026-09-06 04:57:16', '2026-09-06 10:26:34'),
(4, 4, 2, 5, '2026-09-07 06:44:22', '2026-09-06 10:30:27');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_payments`
--

CREATE TABLE `tmn_payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'INR',
  `payment_method` enum('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `status` enum('VALID','VOIDED') NOT NULL DEFAULT 'VALID',
  `voided_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_payments`
--

INSERT INTO `tmn_payments` (`id`, `invoice_id`, `payment_date`, `amount`, `currency_code`, `payment_method`, `reference_number`, `remarks`, `status`, `voided_at`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-09-03', 1500.00, 'INR', 'UPI', 'DEMO-UPI-001', 'Development-only sample payment', 'VALID', NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(2, 7, '2026-09-03', 2500.00, 'INR', 'CASH', 'TMN 2026-000003', '1800 payment and 700 advance for next part', 'VALID', NULL, '2026-09-03 15:30:15', '2026-09-03 15:30:15'),
(3, 2, '2026-09-03', 1300.00, 'INR', 'CASH', 'TMN 2026-000002', 'Fully paid', 'VALID', NULL, '2026-09-03 15:33:37', '2026-09-03 15:33:37'),
(4, 9, '2026-09-03', 2500.00, 'INR', 'CASH', 'TMN 2026-000005', '500 excess payment for the next month', 'VALID', NULL, '2026-09-03 15:58:13', '2026-09-03 15:58:13'),
(5, 10, '2026-09-03', 1500.00, 'INR', 'CASH', 'TMN 2026-000006', 'Full payment', 'VALID', NULL, '2026-09-03 16:07:17', '2026-09-03 16:07:17'),
(6, 1, '2026-09-03', 4500.00, 'INR', 'CASH', 'Extra received for future', NULL, 'VALID', NULL, '2026-09-03 20:32:02', '2026-09-03 20:32:02'),
(7, 11, '2026-09-07', 500.00, 'INR', 'CASH', NULL, NULL, 'VALID', NULL, '2026-09-07 17:00:09', '2026-09-07 17:00:09'),
(8, 13, '2026-09-02', 2400.00, 'INR', 'UPI', 'PMT-TMN-2026-000009', 'Advance payment made for both members', 'VALID', NULL, '2026-09-08 19:42:27', '2026-09-08 19:42:27'),
(9, 14, '2026-09-01', 2000.00, 'INR', 'UPI', 'PMT-TMN-00010', 'Advance payment made for both Srinjini and Srinjoy', 'VALID', NULL, '2026-09-08 19:54:30', '2026-09-08 19:54:30'),
(10, 15, '2026-09-08', 1200.00, 'INR', 'UPI', 'PMT-TMN-2026-000011', 'Paid 1200/- for August 2026', 'VALID', NULL, '2026-09-09 06:53:56', '2026-09-09 06:53:56'),
(11, 17, '2026-09-01', 800.00, 'INR', 'UPI', 'PMT-TMN-2026-000013', 'Paid in time', 'VALID', NULL, '2026-09-09 07:01:38', '2026-09-09 07:01:38'),
(12, 19, '2026-09-07', 1000.00, 'INR', 'UPI', 'PMT-TMN-2026-000015', 'Paid in time', 'VALID', NULL, '2026-09-09 07:44:19', '2026-09-09 07:44:19'),
(13, 20, '2026-08-01', 2000.00, 'INR', 'UPI', 'PMT-TMN-2026-000016', 'Paid on time', 'VALID', NULL, '2026-09-09 08:48:47', '2026-09-09 08:48:47');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_purge_runs`
--

CREATE TABLE `tmn_purge_runs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `initiated_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `backup_run_id` bigint(20) UNSIGNED DEFAULT NULL,
  `mode` enum('PREVIEW','EXECUTED') NOT NULL,
  `cutoff_date` date NOT NULL,
  `status` enum('RUNNING','SUCCEEDED','FAILED') NOT NULL DEFAULT 'RUNNING',
  `row_counts_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`row_counts_json`)),
  `error_summary` varchar(500) DEFAULT NULL,
  `started_at` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tmn_refunds`
--

CREATE TABLE `tmn_refunds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED DEFAULT NULL,
  `payment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `credit_id` bigint(20) UNSIGNED DEFAULT NULL,
  `refund_type` enum('PAYMENT','CREDIT','ADJUSTMENT') NOT NULL,
  `refund_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL,
  `refund_method` enum('CASH','UPI','BANK_TRANSFER','CARD','OTHER') NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `reason` varchar(500) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `tmn_refunds`
--

INSERT INTO `tmn_refunds` (`id`, `teacher_student_id`, `invoice_id`, `payment_id`, `credit_id`, `refund_type`, `refund_date`, `amount`, `currency_code`, `refund_method`, `reference_number`, `reason`, `created_at`) VALUES
(1, 1, NULL, NULL, NULL, 'ADJUSTMENT', '2026-09-03', 500.00, 'INR', 'OTHER', 'R-500', 'Arbitrari', '2026-09-03 20:43:36'),
(2, 1, NULL, NULL, 3, 'CREDIT', '2026-09-03', 3000.00, 'INR', 'BANK_TRANSFER', 'Extra payment refunded', 'Extra payment refunded', '2026-09-03 20:45:57');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_responsibilities`
--

CREATE TABLE `tmn_responsibilities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `responsibility_for` enum('TEACHER','STUDENT') NOT NULL,
  `title` varchar(200) NOT NULL,
  `details` text DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_responsibilities`
--

INSERT INTO `tmn_responsibilities` (`id`, `teacher_student_id`, `responsibility_for`, `title`, `details`, `status`, `effective_from`, `effective_to`, `created_at`, `updated_at`) VALUES
(1, 1, 'TEACHER', 'Provide regular assignments', NULL, 'ACTIVE', '2026-01-01', NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(2, 1, 'STUDENT', 'Attend classes regularly', NULL, 'ACTIVE', '2026-01-01', NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_student_billing`
--

CREATE TABLE `tmn_student_billing` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `rule_name` varchar(100) DEFAULT NULL,
  `billing_mode` enum('FIXED_MONTHLY','HOURLY') NOT NULL,
  `rate` decimal(12,2) NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'INR',
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_student_billing`
--

INSERT INTO `tmn_student_billing` (`id`, `teacher_student_id`, `rule_name`, `billing_mode`, `rate`, `currency_code`, `effective_from`, `effective_to`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Hourly rule #1', 'HOURLY', 300.00, 'INR', '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-03 19:53:30'),
(2, 2, 'Monthly rule #2', 'FIXED_MONTHLY', 2000.00, 'INR', '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-03 19:53:30'),
(7, 2, 'R1-300', 'HOURLY', 300.00, 'INR', '2026-09-03', NULL, 'ACTIVE', '2026-09-03 20:12:23', '2026-09-03 20:12:23'),
(8, 12, 'Arup-300', 'HOURLY', 300.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 15:19:41', '2026-09-07 15:19:41'),
(9, 9, 'Barid-250', 'HOURLY', 250.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 15:20:46', '2026-09-09 07:07:26'),
(10, 10, 'Biswajit-300', 'HOURLY', 300.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 15:21:57', '2026-09-07 15:21:57'),
(11, 18, 'MonalisaDas-1000', 'FIXED_MONTHLY', 1000.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 20:07:30', '2026-09-09 06:55:45'),
(12, 23, 'BratatiBiswas-800', 'FIXED_MONTHLY', 800.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 20:09:20', '2026-09-09 06:57:47'),
(13, 17, 'MohitRaha-1000', 'FIXED_MONTHLY', 1000.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 20:10:35', '2026-09-09 07:03:07'),
(14, 22, 'AbhigyanPaul-300', 'HOURLY', 300.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 20:12:48', '2026-09-07 20:12:48'),
(15, 25, 'IshanDey-1200', 'FIXED_MONTHLY', 1200.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 20:14:03', '2026-09-09 06:48:34'),
(16, 20, 'AdityaRoy-300', 'HOURLY', 300.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 20:15:25', '2026-09-07 20:15:25'),
(17, 20, 'AdityaRoy-250', 'HOURLY', 250.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 20:16:15', '2026-09-07 20:16:15'),
(18, 19, 'AnishParua-400', 'HOURLY', 400.00, 'INR', '2026-09-07', NULL, 'ACTIVE', '2026-09-07 20:17:28', '2026-09-07 20:17:28'),
(19, 21, 'SandipChakraborty-400', 'HOURLY', 400.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-07 20:18:43', '2026-09-08 12:30:37'),
(20, 26, 'Bihan-Biswas-2000', 'FIXED_MONTHLY', 2000.00, 'INR', '2026-08-01', NULL, 'ACTIVE', '2026-09-08 10:24:57', '2026-09-09 08:46:33');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_student_credits`
--

CREATE TABLE `tmn_student_credits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_student_id` bigint(20) UNSIGNED NOT NULL,
  `source_payment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `source_type` enum('OVERPAYMENT','ADVANCE') NOT NULL DEFAULT 'OVERPAYMENT',
  `received_date` date DEFAULT NULL,
  `received_method` enum('CASH','UPI','BANK_TRANSFER','CARD','OTHER') DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `currency_code` char(3) NOT NULL,
  `original_amount` decimal(12,2) NOT NULL,
  `remaining_amount` decimal(12,2) NOT NULL,
  `status` enum('ACTIVE','EXHAUSTED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_student_credits`
--

INSERT INTO `tmn_student_credits` (`id`, `teacher_student_id`, `source_payment_id`, `source_type`, `received_date`, `received_method`, `reference_number`, `remarks`, `currency_code`, `original_amount`, `remaining_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 2, 'OVERPAYMENT', NULL, NULL, NULL, NULL, 'INR', 700.00, 0.00, 'EXHAUSTED', '2026-09-03 15:30:15', '2026-09-03 15:31:59'),
(2, 2, 4, 'OVERPAYMENT', NULL, NULL, NULL, NULL, 'INR', 500.00, 0.00, 'EXHAUSTED', '2026-09-03 15:58:13', '2026-09-03 16:00:46'),
(3, 1, 6, 'OVERPAYMENT', NULL, NULL, NULL, NULL, 'INR', 3000.00, 0.00, 'EXHAUSTED', '2026-09-03 20:32:02', '2026-09-03 20:45:57'),
(4, 21, NULL, 'ADVANCE', '2026-08-22', 'UPI', 'Sandip-Adv-22-08-2026', 'Advance for next three classes', 'INR', 1200.00, 1200.00, 'ACTIVE', '2026-09-08 17:31:13', '2026-09-08 17:31:13');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_student_profiles`
--

CREATE TABLE `tmn_student_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address_line1` varchar(255) DEFAULT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state_name` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country_code` char(2) DEFAULT NULL,
  `guardian_name` varchar(200) DEFAULT NULL,
  `guardian_phone` varchar(30) DEFAULT NULL,
  `profile_details` text DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_student_profiles`
--

INSERT INTO `tmn_student_profiles` (`user_id`, `first_name`, `last_name`, `phone`, `address_line1`, `address_line2`, `city`, `state_name`, `postal_code`, `country_code`, `guardian_name`, `guardian_phone`, `profile_details`, `photo_path`, `created_at`, `updated_at`) VALUES
(4, 'Kavya', 'Sharma', '9000000011', 'Flat no 3', 'Munawara', 'Pune', 'Maharashtra', '6475674', NULL, 'Neha Sharma', '9000001011', 'I am a student', '/Tuman/uploads/profile-photos/f7889eab0c92b522e6a85ffade13340e4c02a682.png', '2026-09-02 11:21:51', '2026-09-03 12:04:40'),
(5, 'Arjun', 'Patel', '9000000012', 'House 26', 'Banarghata Road', 'Bangalore', 'Telengana', '8956746', NULL, 'Ravi Patel', '9000001012', 'I am a AI enthuciast', '/Tuman/uploads/profile-photos/f98d816d8b4c27f08dec36f62c24c0f1c005ba51.png', '2026-09-02 11:21:51', '2026-09-05 18:47:52'),
(6, 'Meera', 'Iyer', '9000000013', NULL, NULL, 'Pune', NULL, NULL, NULL, 'Lakshmi Iyer', '9000001013', NULL, NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(7, 'Rohan', 'Das', '9000000014', NULL, NULL, 'Pune', NULL, NULL, NULL, 'Anita Das', '9000001014', NULL, NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(15, 'Arup', 'Kulavi', '07003611603', NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 12:44:08', '2026-09-07 12:44:08'),
(16, 'Barid', 'Biswas', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 14:48:40', '2026-09-07 14:48:40'),
(17, 'Biswajit', 'Biswas', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 14:51:00', '2026-09-07 14:51:00'),
(18, 'Moutushi', 'Biswas', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 14:52:46', '2026-09-07 14:52:46'),
(19, 'Arup', 'Kulavi', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 15:18:14', '2026-09-07 15:18:14'),
(20, 'Debayudh', 'Bhattacharya', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:21:24', '2026-09-07 18:27:23'),
(21, 'Antarip', 'Bhattacharya', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:23:11', '2026-09-07 18:27:01'),
(22, 'Srinjini', 'Saha', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:24:23', '2026-09-07 18:26:38'),
(23, 'Srinjoy', 'Saha', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:25:35', '2026-09-07 18:25:35'),
(24, 'Mohit', 'Raha', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:28:51', '2026-09-07 18:28:51'),
(25, 'Monalisa', 'Das', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:29:58', '2026-09-07 18:30:29'),
(26, 'Anish', 'Parua', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:31:43', '2026-09-07 18:31:43'),
(27, 'Aditya', 'Roy', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:32:59', '2026-09-07 18:34:03'),
(28, 'Sandip', 'Chakraborty', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:35:43', '2026-09-07 18:35:43'),
(29, 'Abhigyan', 'Paul', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:38:32', '2026-09-07 18:39:00'),
(30, 'Bratati', 'Biswas', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-07 18:40:17', '2026-09-07 18:40:17'),
(31, 'Megi', 'Dana', NULL, NULL, NULL, NULL, NULL, NULL, 'GB', NULL, NULL, NULL, NULL, '2026-09-07 18:43:15', '2026-09-07 18:43:15'),
(32, 'Ishan', 'Dey', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-07 18:52:28', '2026-09-07 18:52:28'),
(34, 'Bihan', 'Biswas', NULL, NULL, NULL, NULL, NULL, NULL, 'IN', NULL, NULL, NULL, NULL, '2026-09-08 10:23:16', '2026-09-08 10:23:16');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_system_settings`
--

CREATE TABLE `tmn_system_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` varchar(1000) NOT NULL,
  `updated_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_system_settings`
--

INSERT INTO `tmn_system_settings` (`setting_key`, `setting_value`, `updated_by_user_id`, `updated_at`) VALUES
('application_name', 'Tuman', NULL, '2026-09-02 11:21:51'),
('default_currency', 'INR', NULL, '2026-09-02 11:21:51');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_teacher_payment_details`
--

CREATE TABLE `tmn_teacher_payment_details` (
  `teacher_user_id` bigint(20) UNSIGNED NOT NULL,
  `indian_account_holder` varchar(200) DEFAULT NULL,
  `indian_bank_name` varchar(200) DEFAULT NULL,
  `indian_branch` varchar(200) DEFAULT NULL,
  `indian_account_number` varchar(100) DEFAULT NULL,
  `indian_ifsc` varchar(30) DEFAULT NULL,
  `indian_upi_id` varchar(100) DEFAULT NULL,
  `indian_pan_gstin` varchar(50) DEFAULT NULL,
  `indian_reference_note` varchar(500) DEFAULT NULL,
  `international_beneficiary` varchar(200) DEFAULT NULL,
  `international_bank_name` varchar(200) DEFAULT NULL,
  `international_bank_address` varchar(500) DEFAULT NULL,
  `international_account_iban` varchar(100) DEFAULT NULL,
  `international_swift_bic` varchar(30) DEFAULT NULL,
  `international_intermediary_details` varchar(500) DEFAULT NULL,
  `international_fee_note` varchar(500) DEFAULT NULL,
  `international_reference_note` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_teacher_payment_details`
--

INSERT INTO `tmn_teacher_payment_details` (`teacher_user_id`, `indian_account_holder`, `indian_bank_name`, `indian_branch`, `indian_account_number`, `indian_ifsc`, `indian_upi_id`, `indian_pan_gstin`, `indian_reference_note`, `international_beneficiary`, `international_bank_name`, `international_bank_address`, `international_account_iban`, `international_swift_bic`, `international_intermediary_details`, `international_fee_note`, `international_reference_note`, `created_at`, `updated_at`) VALUES
(2, 'Alisha Patiha', 'HDFC', 'Kalyani', '00124356748', 'KAL004HDFC', 'alishapatiha@okhdfcbank', NULL, 'Send INR Payment here', 'Alisha Patiha', 'HDFC', 'Kalyani', '00124356748', '784935637', NULL, NULL, NULL, '2026-09-02 19:39:54', '2026-09-02 19:39:54');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_teacher_profiles`
--

CREATE TABLE `tmn_teacher_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address_line1` varchar(255) DEFAULT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state_name` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `profile_details` text DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_teacher_profiles`
--

INSERT INTO `tmn_teacher_profiles` (`user_id`, `first_name`, `last_name`, `phone`, `address_line1`, `address_line2`, `city`, `state_name`, `postal_code`, `profile_details`, `photo_path`, `created_at`, `updated_at`) VALUES
(2, 'Aisha', 'Khan', '9000000001', 'Flat No 5', 'Pandurang Road', 'Pune', 'Mahrashtra', '864758', 'I  am a Computer teacher', '/Tuman/uploads/profile-photos/60fb71e8b6740b312b92ad8171e40a48171c6f3c.png', '2026-09-02 11:21:51', '2026-09-05 18:42:32'),
(3, 'Rahul', 'Verma', '9000000002', NULL, NULL, 'Pune', NULL, NULL, NULL, NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(14, 'Santanu', 'Karmakar', '91-9903366519', 'A-9/33, Kalyani', 'Nadia, West Bengal', 'Kalyani', 'West Bengal', '741235', 'I am a teacher with 35 years of industry experience. I have worked last 3 years on AI related developments.', '/Tuman/uploads/profile-photos/9f1277224a83b7d5b04a849d957ae0ab808f2c75.jpg', '2026-09-03 11:58:36', '2026-09-03 11:58:56');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_teacher_students`
--

CREATE TABLE `tmn_teacher_students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_user_id` bigint(20) UNSIGNED NOT NULL,
  `student_user_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `tmn_teacher_students`
--

INSERT INTO `tmn_teacher_students` (`id`, `teacher_user_id`, `student_user_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 4, '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(2, 2, 5, '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(3, 3, 6, '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(4, 3, 7, '2026-01-01', NULL, 'ACTIVE', '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(6, 14, 4, '2026-09-03', '2026-09-07', 'INACTIVE', '2026-09-03 10:25:55', '2026-09-07 14:49:11'),
(7, 14, 5, '2026-09-03', '2026-09-07', 'INACTIVE', '2026-09-03 10:29:37', '2026-09-07 14:49:01'),
(8, 2, 15, '2026-09-07', NULL, 'ACTIVE', '2026-09-07 12:44:08', '2026-09-07 12:44:08'),
(9, 14, 16, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 14:48:40', '2026-09-09 06:45:29'),
(10, 14, 17, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 14:51:00', '2026-09-08 08:40:38'),
(11, 14, 18, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 14:52:46', '2026-09-08 08:43:09'),
(12, 14, 19, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 15:18:14', '2026-09-08 08:40:19'),
(13, 14, 20, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 18:21:24', '2026-09-08 08:41:29'),
(14, 14, 21, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 18:23:11', '2026-09-08 08:38:53'),
(15, 14, 22, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 18:24:23', '2026-09-08 08:44:09'),
(16, 14, 23, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 18:25:35', '2026-09-08 08:44:37'),
(17, 14, 24, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:28:51', '2026-09-09 07:02:31'),
(18, 14, 25, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:29:58', '2026-09-09 06:54:55'),
(19, 14, 26, '2026-09-01', NULL, 'ACTIVE', '2026-09-07 18:31:43', '2026-09-08 08:38:27'),
(20, 14, 27, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:32:59', '2026-09-09 07:06:30'),
(21, 14, 28, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:35:43', '2026-09-08 12:21:20'),
(22, 14, 29, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:38:32', '2026-09-09 07:05:54'),
(23, 14, 30, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:40:17', '2026-09-09 06:57:13'),
(24, 14, 31, '2026-09-07', NULL, 'ACTIVE', '2026-09-07 18:43:15', '2026-09-07 18:43:15'),
(25, 14, 32, '2026-08-01', NULL, 'ACTIVE', '2026-09-07 18:52:28', '2026-09-09 06:46:14'),
(26, 33, 34, '2026-08-01', NULL, 'ACTIVE', '2026-09-08 10:23:16', '2026-09-09 08:46:04');

-- --------------------------------------------------------

--
-- Table structure for table `tmn_users`
--

CREATE TABLE `tmn_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(254) DEFAULT NULL,
  `role` enum('ADMIN','TEACHER','STUDENT') NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tmn_users`
--

INSERT INTO `tmn_users` (`id`, `username`, `password_hash`, `email`, `role`, `status`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'admin.demo', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'admin.demo@example.test', 'ADMIN', 'ACTIVE', '2026-09-07 06:22:57', '2026-09-02 11:21:51', '2026-09-07 11:52:57'),
(2, 'teacher.aisha', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'aisha@example.test', 'TEACHER', 'ACTIVE', '2026-09-08 04:47:33', '2026-09-02 11:21:51', '2026-09-08 10:17:57'),
(3, 'teacher.rahul', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'rahul@example.test', 'TEACHER', 'ACTIVE', NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(4, 'student.kavya', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'kavya@example.test', 'STUDENT', 'ACTIVE', '2026-09-03 06:29:40', '2026-09-02 11:21:51', '2026-09-03 11:59:40'),
(5, 'student.arjun', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'sann8nplayground@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-06 05:00:01', '2026-09-02 11:21:51', '2026-09-06 10:30:01'),
(6, 'student.meera', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'meera@example.test', 'STUDENT', 'ACTIVE', '2026-09-02 13:29:56', '2026-09-02 11:21:51', '2026-09-02 18:59:56'),
(7, 'student.rohan', '$2y$10$0WfC84ipWFt5BjuRuSKqiONsM0zcvWsqyvnNJOkZuB1lQdX1CficC', 'rohan@example.test', 'STUDENT', 'ACTIVE', NULL, '2026-09-02 11:21:51', '2026-09-02 11:21:51'),
(12, 'admin.santanu', '$2y$12$wmdS2JlU9ZR08k.n8sWSlOo9oMBbaWlwOJLzLXDygROfsmtR0KnwC', 'fromsantanu@gmail.com', 'ADMIN', 'ACTIVE', '2026-09-08 04:48:14', '2026-09-03 09:41:10', '2026-09-08 10:18:14'),
(14, 'teacher.santanu', '$2y$12$dExTiBrOTMHC0HiKDGKBSum1reMfbMoEn3VVPXwDc7PVGMT7DaKCi', 'fromsantanuact@gmail.com', 'TEACHER', 'ACTIVE', '2026-09-09 03:11:37', '2026-09-03 09:45:05', '2026-09-09 08:41:37'),
(15, 'akulavi', '$2y$12$EMdt2p/o/3G/2Q9FWcD.u.jY7vZRTjR0X1F5UYkzM4s5W7CoZrx9y', 'akulavi@yahoo.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 12:44:08', '2026-09-07 12:44:08'),
(16, 'student.barid.biswas', '$2y$12$UIgqKS1umj5t9OgQF1SB1ua2/5gfhdV7eELDXW2Nt2xrPhaIrSGhe', 'student1@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-09 02:14:40', '2026-09-07 14:48:40', '2026-09-09 07:44:40'),
(17, 'student.biswajit.biswass', '$2y$12$EgWZi03F.8PeherPLVznQ.aWwNzjETFVI0M5qQ/RZPl3GWxRikLHy', 'student2@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 14:51:00', '2026-09-07 14:51:00'),
(18, 'student.moutushi.biswas', '$2y$12$Dau7CnLRxNUoNvPO6arjZ.phXABt16S83rI2D6frpb.EdvrMGq6PG', 'student3@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-07 09:30:46', '2026-09-07 14:52:46', '2026-09-07 15:00:46'),
(19, 'student.arup.kulavi', '$2y$12$2tFgZI3ZJsUCO58XfcB1F.GPVIuraJUr6jic4EaSleUgQMmPdBiOq', 'student4@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 15:18:14', '2026-09-07 15:18:14'),
(20, 'student.debayudh.bhattacharya', '$2y$12$ibCm0W.WWPMfmgRaG8YKRuh49AduDKaZmKbZ93U8roMAsF4nQiamS', 'student5@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-08 14:13:37', '2026-09-07 18:21:24', '2026-09-08 19:43:37'),
(21, 'student.antarip.bhattacharya', '$2y$12$f0Yn3VJXjWXs0H64jXPjMe5DnKTPzChIgvNpZonAgHM3MWh4exZ5y', 'student6@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:23:11', '2026-09-07 18:23:11'),
(22, 'student.srinjini.saha', '$2y$12$Qk/kHUpeFjhgsgu8u4Y3kuvNrMRR0oqXl2s19z2mckmHeTs7v1/WO', 'student7@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-08 14:25:25', '2026-09-07 18:24:23', '2026-09-08 19:55:25'),
(23, 'student.srinjoy.saha', '$2y$12$YYdB9phUgTr13IfXsNwvSuammaXC8tjmCCBvCRp6CZZ6JjgzBBjNa', 'student8@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:25:35', '2026-09-07 18:25:35'),
(24, 'student.mohit.raha', '$2y$12$Iq9vnD/C8ZptXzex0ZPOVu2QWikxcbbQ.Zch42SbabVzPX/U6OzNy', 'student9@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:28:51', '2026-09-07 18:28:51'),
(25, 'student.monalisa.das', '$2y$12$bghhSAEZrm.sZv.9wl.jMeCv.Cb3JLPQY70sBsAhhCTgto/aHI2P6', 'student10@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:29:58', '2026-09-07 18:29:58'),
(26, 'student.anish.parua', '$2y$12$oO/b284Bcu8wplLHDGMI5egbXOE0nC521avZM/0giU3pDDwzmCCd2', 'student11@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:31:43', '2026-09-07 18:31:43'),
(27, 'student.aditya.roy', '$2y$12$Womi0QbGC8WMYahK2rlG8eklhEqaf7uEul4jxyakRVW6nWpmOZb9.', 'student12@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-07 15:01:12', '2026-09-07 18:32:59', '2026-09-07 20:31:12'),
(28, 'student.sandip.chakraborty', '$2y$12$WsKOL/QUGrkgruBQOhL0LOAvrVkpWDzNfMItTAjvPeycUkoJQHHsS', 'student13@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-08 12:01:44', '2026-09-07 18:35:43', '2026-09-08 17:31:44'),
(29, 'student.abhigyan.paul', '$2y$12$EST9e8m7qiTPtnuJDfV1/OnPb5Okip1AOcH4FNzGwe0Mzk0fYUTeu', 'student14@gmail.com', 'STUDENT', 'ACTIVE', '2026-09-08 04:41:17', '2026-09-07 18:38:32', '2026-09-08 10:11:17'),
(30, 'student.bratati.biswas', '$2y$12$a3ncbb29LmSppvMaIuCRmeNLCxEdvk.Prr4dH43h6BbyOMUqS01S6', 'student15@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:40:17', '2026-09-07 18:40:17'),
(31, 'student.megi.dana', '$2y$12$usdqEvEV5V3G3kYFv805xeFIVny5TJfplvwe2wggN5erImg/XiFMy', 'student16@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:43:15', '2026-09-07 18:43:15'),
(32, 'student.ishan.dey', '$2y$12$7INiBIcuqvlOntVUv6QnienRJS6c7SrUOQmqBdkQ2kfXFRDpKnnHq', 'student17@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-07 18:52:28', '2026-09-07 18:52:28'),
(33, 'teacher.mita.karmakar', '$2y$12$wAzdjcKj1G6ArDBJ2I66p.hcDc44LOw9Q36dVGx6S9v.JySdqkXQi', 'mitaksept@gmail.com', 'TEACHER', 'ACTIVE', '2026-09-09 03:15:44', '2026-09-08 10:20:03', '2026-09-09 08:45:44'),
(34, 'student.bihan.biswas', '$2y$12$PzgBfO9UtYmjeZvPTBxhZe5ivmOnT/Gjewp3QIe9GETIXeiyu2y1G', 'student18@gmail.com', 'STUDENT', 'ACTIVE', NULL, '2026-09-08 10:23:16', '2026-09-08 10:23:16');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tmn_activity_log`
--
ALTER TABLE `tmn_activity_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_activity_log_actor_created` (`actor_user_id`,`created_at`),
  ADD KEY `idx_tmn_activity_log_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `tmn_admin_profiles`
--
ALTER TABLE `tmn_admin_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `tmn_attendance`
--
ALTER TABLE `tmn_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_attendance_session` (`teacher_student_id`,`session_date`,`start_time`),
  ADD KEY `idx_tmn_attendance_assignment_date` (`teacher_student_id`,`session_date`),
  ADD KEY `fk_tmn_attendance_billing_rule` (`billing_rule_id`),
  ADD KEY `idx_tmn_attendance_batch_date` (`batch_id`,`session_date`),
  ADD KEY `fk_tmn_attendance_batch_billing_rule` (`batch_billing_rule_id`);

--
-- Indexes for table `tmn_backup_runs`
--
ALTER TABLE `tmn_backup_runs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tmn_backup_runs_initiator` (`initiated_by_user_id`),
  ADD KEY `idx_tmn_backup_runs_status_completed` (`status`,`completed_at`);

--
-- Indexes for table `tmn_batches`
--
ALTER TABLE `tmn_batches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_batches_teacher_name` (`teacher_user_id`,`batch_name`),
  ADD KEY `idx_tmn_batches_teacher_status` (`teacher_user_id`,`status`);

--
-- Indexes for table `tmn_batch_billing_rules`
--
ALTER TABLE `tmn_batch_billing_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_batch_billing_rules_code` (`batch_id`,`rule_code`),
  ADD KEY `idx_tmn_batch_billing_rules_batch_status` (`batch_id`,`status`);

--
-- Indexes for table `tmn_batch_students`
--
ALTER TABLE `tmn_batch_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_batch_students_member` (`batch_id`,`teacher_student_id`),
  ADD KEY `idx_tmn_batch_students_assignment_status` (`teacher_student_id`,`status`);

--
-- Indexes for table `tmn_credit_applications`
--
ALTER TABLE `tmn_credit_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_credit_applications_credit` (`credit_id`),
  ADD KEY `idx_tmn_credit_applications_invoice` (`invoice_id`);

--
-- Indexes for table `tmn_credit_refunds`
--
ALTER TABLE `tmn_credit_refunds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_credit_refunds_credit_date` (`credit_id`,`refund_date`);

--
-- Indexes for table `tmn_email_log`
--
ALTER TABLE `tmn_email_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_email_log_related_entity` (`related_entity_type`,`related_entity_id`),
  ADD KEY `idx_tmn_email_log_status_created` (`delivery_status`,`created_at`);

--
-- Indexes for table `tmn_invoices`
--
ALTER TABLE `tmn_invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_invoices_number` (`invoice_number`),
  ADD KEY `idx_tmn_invoices_assignment_date` (`teacher_student_id`,`invoice_date`),
  ADD KEY `idx_tmn_invoices_period` (`billing_period_from`,`billing_period_to`),
  ADD KEY `idx_tmn_invoices_batch_period` (`batch_id`,`billing_period_from`,`billing_period_to`),
  ADD KEY `idx_tmn_invoices_batch_rule_period` (`batch_billing_rule_id`,`billing_period_from`,`billing_period_to`);

--
-- Indexes for table `tmn_invoice_items`
--
ALTER TABLE `tmn_invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_invoice_items_invoice_sort` (`invoice_id`,`sort_order`);

--
-- Indexes for table `tmn_invoice_sequences`
--
ALTER TABLE `tmn_invoice_sequences`
  ADD PRIMARY KEY (`sequence_scope`);

--
-- Indexes for table `tmn_messages`
--
ALTER TABLE `tmn_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_messages_sender_created` (`sender_user_id`,`created_at`);

--
-- Indexes for table `tmn_message_recipients`
--
ALTER TABLE `tmn_message_recipients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_message_recipient` (`message_id`,`recipient_user_id`),
  ADD KEY `fk_tmn_message_recipients_email_log` (`email_log_id`),
  ADD KEY `idx_tmn_message_recipients_unread` (`recipient_user_id`,`read_at`,`created_at`);

--
-- Indexes for table `tmn_payments`
--
ALTER TABLE `tmn_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_payments_invoice_status` (`invoice_id`,`status`),
  ADD KEY `idx_tmn_payments_date` (`payment_date`);

--
-- Indexes for table `tmn_purge_runs`
--
ALTER TABLE `tmn_purge_runs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tmn_purge_runs_initiator` (`initiated_by_user_id`),
  ADD KEY `fk_tmn_purge_runs_backup` (`backup_run_id`),
  ADD KEY `idx_tmn_purge_runs_status_completed` (`status`,`completed_at`),
  ADD KEY `idx_tmn_purge_runs_cutoff` (`cutoff_date`);

--
-- Indexes for table `tmn_refunds`
--
ALTER TABLE `tmn_refunds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_refunds_assignment_date` (`teacher_student_id`,`refund_date`),
  ADD KEY `idx_tmn_refunds_payment` (`payment_id`),
  ADD KEY `idx_tmn_refunds_credit` (`credit_id`),
  ADD KEY `idx_tmn_refunds_invoice` (`invoice_id`);

--
-- Indexes for table `tmn_responsibilities`
--
ALTER TABLE `tmn_responsibilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tmn_responsibilities_assignment_status` (`teacher_student_id`,`status`);

--
-- Indexes for table `tmn_student_billing`
--
ALTER TABLE `tmn_student_billing`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_student_billing_assignment_name` (`teacher_student_id`,`rule_name`),
  ADD KEY `idx_tmn_student_billing_assignment_date` (`teacher_student_id`,`effective_from`);

--
-- Indexes for table `tmn_student_credits`
--
ALTER TABLE `tmn_student_credits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_student_credits_source_payment` (`source_payment_id`),
  ADD KEY `idx_tmn_student_credits_assignment_currency` (`teacher_student_id`,`currency_code`,`status`);

--
-- Indexes for table `tmn_student_profiles`
--
ALTER TABLE `tmn_student_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `tmn_system_settings`
--
ALTER TABLE `tmn_system_settings`
  ADD PRIMARY KEY (`setting_key`),
  ADD KEY `fk_tmn_system_settings_user` (`updated_by_user_id`);

--
-- Indexes for table `tmn_teacher_payment_details`
--
ALTER TABLE `tmn_teacher_payment_details`
  ADD PRIMARY KEY (`teacher_user_id`);

--
-- Indexes for table `tmn_teacher_profiles`
--
ALTER TABLE `tmn_teacher_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `tmn_teacher_students`
--
ALTER TABLE `tmn_teacher_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_teacher_students_pair` (`teacher_user_id`,`student_user_id`),
  ADD KEY `idx_tmn_teacher_students_teacher_status` (`teacher_user_id`,`status`),
  ADD KEY `idx_tmn_teacher_students_student_status` (`student_user_id`,`status`);

--
-- Indexes for table `tmn_users`
--
ALTER TABLE `tmn_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tmn_users_username` (`username`),
  ADD UNIQUE KEY `uq_tmn_users_email` (`email`),
  ADD KEY `idx_tmn_users_role_status` (`role`,`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tmn_activity_log`
--
ALTER TABLE `tmn_activity_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=240;

--
-- AUTO_INCREMENT for table `tmn_attendance`
--
ALTER TABLE `tmn_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_backup_runs`
--
ALTER TABLE `tmn_backup_runs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `tmn_batches`
--
ALTER TABLE `tmn_batches`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_batch_billing_rules`
--
ALTER TABLE `tmn_batch_billing_rules`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_batch_students`
--
ALTER TABLE `tmn_batch_students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tmn_credit_applications`
--
ALTER TABLE `tmn_credit_applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_credit_refunds`
--
ALTER TABLE `tmn_credit_refunds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_email_log`
--
ALTER TABLE `tmn_email_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tmn_invoices`
--
ALTER TABLE `tmn_invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_invoice_items`
--
ALTER TABLE `tmn_invoice_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_messages`
--
ALTER TABLE `tmn_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tmn_message_recipients`
--
ALTER TABLE `tmn_message_recipients`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tmn_payments`
--
ALTER TABLE `tmn_payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_purge_runs`
--
ALTER TABLE `tmn_purge_runs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_refunds`
--
ALTER TABLE `tmn_refunds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_responsibilities`
--
ALTER TABLE `tmn_responsibilities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_student_billing`
--
ALTER TABLE `tmn_student_billing`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_student_credits`
--
ALTER TABLE `tmn_student_credits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_teacher_students`
--
ALTER TABLE `tmn_teacher_students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmn_users`
--
ALTER TABLE `tmn_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tmn_activity_log`
--
ALTER TABLE `tmn_activity_log`
  ADD CONSTRAINT `fk_tmn_activity_log_actor` FOREIGN KEY (`actor_user_id`) REFERENCES `tmn_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tmn_admin_profiles`
--
ALTER TABLE `tmn_admin_profiles`
  ADD CONSTRAINT `fk_tmn_admin_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_attendance`
--
ALTER TABLE `tmn_attendance`
  ADD CONSTRAINT `fk_tmn_attendance_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`),
  ADD CONSTRAINT `fk_tmn_attendance_batch` FOREIGN KEY (`batch_id`) REFERENCES `tmn_batches` (`id`),
  ADD CONSTRAINT `fk_tmn_attendance_batch_billing_rule` FOREIGN KEY (`batch_billing_rule_id`) REFERENCES `tmn_batch_billing_rules` (`id`),
  ADD CONSTRAINT `fk_tmn_attendance_billing_rule` FOREIGN KEY (`billing_rule_id`) REFERENCES `tmn_student_billing` (`id`);

--
-- Constraints for table `tmn_backup_runs`
--
ALTER TABLE `tmn_backup_runs`
  ADD CONSTRAINT `fk_tmn_backup_runs_initiator` FOREIGN KEY (`initiated_by_user_id`) REFERENCES `tmn_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tmn_batches`
--
ALTER TABLE `tmn_batches`
  ADD CONSTRAINT `fk_tmn_batches_teacher` FOREIGN KEY (`teacher_user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_batch_billing_rules`
--
ALTER TABLE `tmn_batch_billing_rules`
  ADD CONSTRAINT `fk_tmn_batch_billing_rules_batch` FOREIGN KEY (`batch_id`) REFERENCES `tmn_batches` (`id`);

--
-- Constraints for table `tmn_batch_students`
--
ALTER TABLE `tmn_batch_students`
  ADD CONSTRAINT `fk_tmn_batch_students_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`),
  ADD CONSTRAINT `fk_tmn_batch_students_batch` FOREIGN KEY (`batch_id`) REFERENCES `tmn_batches` (`id`);

--
-- Constraints for table `tmn_credit_applications`
--
ALTER TABLE `tmn_credit_applications`
  ADD CONSTRAINT `fk_tmn_credit_applications_credit` FOREIGN KEY (`credit_id`) REFERENCES `tmn_student_credits` (`id`),
  ADD CONSTRAINT `fk_tmn_credit_applications_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tmn_invoices` (`id`);

--
-- Constraints for table `tmn_credit_refunds`
--
ALTER TABLE `tmn_credit_refunds`
  ADD CONSTRAINT `fk_tmn_credit_refunds_credit` FOREIGN KEY (`credit_id`) REFERENCES `tmn_student_credits` (`id`);

--
-- Constraints for table `tmn_invoices`
--
ALTER TABLE `tmn_invoices`
  ADD CONSTRAINT `fk_tmn_invoices_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`),
  ADD CONSTRAINT `fk_tmn_invoices_batch` FOREIGN KEY (`batch_id`) REFERENCES `tmn_batches` (`id`),
  ADD CONSTRAINT `fk_tmn_invoices_batch_billing_rule` FOREIGN KEY (`batch_billing_rule_id`) REFERENCES `tmn_batch_billing_rules` (`id`);

--
-- Constraints for table `tmn_invoice_items`
--
ALTER TABLE `tmn_invoice_items`
  ADD CONSTRAINT `fk_tmn_invoice_items_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tmn_invoices` (`id`);

--
-- Constraints for table `tmn_messages`
--
ALTER TABLE `tmn_messages`
  ADD CONSTRAINT `fk_tmn_messages_sender` FOREIGN KEY (`sender_user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_message_recipients`
--
ALTER TABLE `tmn_message_recipients`
  ADD CONSTRAINT `fk_tmn_message_recipients_email_log` FOREIGN KEY (`email_log_id`) REFERENCES `tmn_email_log` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tmn_message_recipients_message` FOREIGN KEY (`message_id`) REFERENCES `tmn_messages` (`id`),
  ADD CONSTRAINT `fk_tmn_message_recipients_user` FOREIGN KEY (`recipient_user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_payments`
--
ALTER TABLE `tmn_payments`
  ADD CONSTRAINT `fk_tmn_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tmn_invoices` (`id`);

--
-- Constraints for table `tmn_purge_runs`
--
ALTER TABLE `tmn_purge_runs`
  ADD CONSTRAINT `fk_tmn_purge_runs_backup` FOREIGN KEY (`backup_run_id`) REFERENCES `tmn_backup_runs` (`id`),
  ADD CONSTRAINT `fk_tmn_purge_runs_initiator` FOREIGN KEY (`initiated_by_user_id`) REFERENCES `tmn_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tmn_refunds`
--
ALTER TABLE `tmn_refunds`
  ADD CONSTRAINT `fk_tmn_refunds_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`),
  ADD CONSTRAINT `fk_tmn_refunds_credit` FOREIGN KEY (`credit_id`) REFERENCES `tmn_student_credits` (`id`),
  ADD CONSTRAINT `fk_tmn_refunds_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tmn_invoices` (`id`),
  ADD CONSTRAINT `fk_tmn_refunds_payment` FOREIGN KEY (`payment_id`) REFERENCES `tmn_payments` (`id`);

--
-- Constraints for table `tmn_responsibilities`
--
ALTER TABLE `tmn_responsibilities`
  ADD CONSTRAINT `fk_tmn_responsibilities_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`);

--
-- Constraints for table `tmn_student_billing`
--
ALTER TABLE `tmn_student_billing`
  ADD CONSTRAINT `fk_tmn_student_billing_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`);

--
-- Constraints for table `tmn_student_credits`
--
ALTER TABLE `tmn_student_credits`
  ADD CONSTRAINT `fk_tmn_student_credits_assignment` FOREIGN KEY (`teacher_student_id`) REFERENCES `tmn_teacher_students` (`id`),
  ADD CONSTRAINT `fk_tmn_student_credits_payment` FOREIGN KEY (`source_payment_id`) REFERENCES `tmn_payments` (`id`);

--
-- Constraints for table `tmn_student_profiles`
--
ALTER TABLE `tmn_student_profiles`
  ADD CONSTRAINT `fk_tmn_student_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_system_settings`
--
ALTER TABLE `tmn_system_settings`
  ADD CONSTRAINT `fk_tmn_system_settings_user` FOREIGN KEY (`updated_by_user_id`) REFERENCES `tmn_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tmn_teacher_payment_details`
--
ALTER TABLE `tmn_teacher_payment_details`
  ADD CONSTRAINT `fk_tmn_teacher_payment_details_teacher` FOREIGN KEY (`teacher_user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_teacher_profiles`
--
ALTER TABLE `tmn_teacher_profiles`
  ADD CONSTRAINT `fk_tmn_teacher_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `tmn_users` (`id`);

--
-- Constraints for table `tmn_teacher_students`
--
ALTER TABLE `tmn_teacher_students`
  ADD CONSTRAINT `fk_tmn_teacher_students_student` FOREIGN KEY (`student_user_id`) REFERENCES `tmn_users` (`id`),
  ADD CONSTRAINT `fk_tmn_teacher_students_teacher` FOREIGN KEY (`teacher_user_id`) REFERENCES `tmn_users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
