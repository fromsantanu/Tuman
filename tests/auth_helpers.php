<?php
declare(strict_types=1);

// The CLI cannot write to XAMPP's web-server session folder in this workspace.
ini_set('session.save_path', sys_get_temp_dir());

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';

tuman_start_session();
if (tuman_current_user() !== null) {
    throw new RuntimeException('A new session must not be authenticated.');
}
$token = tuman_csrf_token();
if (!tuman_csrf_is_valid($token) || tuman_csrf_is_valid('invalid-token')) {
    throw new RuntimeException('CSRF validation failed.');
}
$before = session_id();
tuman_login(['id' => 101, 'role' => 'TEACHER']);
$user = tuman_current_user();
if ($before === session_id() || $user !== ['id' => 101, 'role' => 'TEACHER']) {
    throw new RuntimeException('Authenticated session setup failed.');
}
tuman_logout();
echo "Authentication helper tests passed.\n";
