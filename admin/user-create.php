<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/includes/auth.php'; require_once dirname(__DIR__) . '/includes/csrf.php'; require_once __DIR__ . '/layout.php'; require_once dirname(__DIR__) . '/services/admin_users.php';
$current = tuman_require_role('ADMIN'); $values = ['username' => '', 'email' => '', 'role' => 'STUDENT']; $error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $values = ['username' => trim((string) ($_POST['username'] ?? '')), 'email' => trim((string) ($_POST['email'] ?? '')), 'role' => (string) ($_POST['role'] ?? '')];
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) { $error = 'Your request could not be verified. Please try again.'; }
    else { try { tuman_admin_create_user(tuman_database(), $current['id'], $values['username'], $values['email'], $values['role'], (string) ($_POST['password'] ?? '')); header('Location: /Tuman/admin/users.php?created=1'); exit; } catch (InvalidArgumentException $exception) { $error = $exception->getMessage(); } catch (Throwable $exception) { error_log('Tuman user creation failed: ' . $exception->getMessage()); $error = 'Unable to create the user right now.'; } }
}
tuman_admin_page_start('Create user');
?>
<h1>Create user</h1><p>New accounts are active by default. Passwords must contain at least 12 characters.</p>
<?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
<form method="post"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><p><label>Username <input name="username" maxlength="50" required value="<?= htmlspecialchars($values['username'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Email <input type="email" name="email" maxlength="254" value="<?= htmlspecialchars($values['email'], ENT_QUOTES, 'UTF-8') ?>"></label></p><p><label>Role <select name="role"><?php foreach (TUMAN_ROLES as $role): ?><option value="<?= $role ?>"<?= $role === $values['role'] ? ' selected' : '' ?>><?= $role ?></option><?php endforeach; ?></select></label></p><p><label>Password <input type="password" name="password" minlength="12" required autocomplete="new-password"></label></p><p><button type="submit">Create user</button> <a href="/Tuman/admin/users.php">Cancel</a></p></form>
<?php tuman_admin_page_end(); ?>
