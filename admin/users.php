<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/includes/auth.php';
require_once __DIR__ . '/layout.php';
require_once dirname(__DIR__) . '/services/admin_users.php';
$current = tuman_require_role('ADMIN');
$error = null; $users = [];
try { $users = tuman_admin_users(tuman_database()); } catch (Throwable $exception) { error_log('Tuman administrator user list failed: ' . $exception->getMessage()); $error = 'Users cannot be loaded right now. Please try again later.'; }
tuman_admin_page_start('Users');
?>
<h1>Users</h1>
<?php if ($error): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php else: ?>
<p><a class="button" href="/Tuman/admin/user-create.php">Create user</a></p>
<div style="overflow-x:auto"><table><thead><tr><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Last login</th><th>Actions</th></tr></thead><tbody>
<?php foreach ($users as $user): ?><tr><td><?= htmlspecialchars($user['username'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($user['email'] ?? '—', ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($user['role'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($user['status'], ENT_QUOTES, 'UTF-8') ?></td><td><?= htmlspecialchars($user['last_login_at'] ?? 'Never', ENT_QUOTES, 'UTF-8') ?></td><td><a href="/Tuman/admin/user-edit.php?id=<?= (int) $user['id'] ?>">Edit</a> · <a href="/Tuman/admin/user-password.php?id=<?= (int) $user['id'] ?>">Reset password</a> · <a href="/Tuman/admin/user-status.php?id=<?= (int) $user['id'] ?>">Status</a></td></tr><?php endforeach; ?>
</tbody></table></div>
<?php endif; tuman_admin_page_end(); ?>
