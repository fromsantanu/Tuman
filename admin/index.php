<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';
require_once __DIR__ . '/layout.php';
tuman_require_role('ADMIN');
tuman_admin_page_start('Administrator dashboard');
?>
<h1>Administrator dashboard</h1>
<p>Manage Tuman user accounts securely. Teacher and Student business features are introduced in later phases.</p>
<p><a class="button" href="/Tuman/admin/users.php">View users</a> <a class="button" href="/Tuman/admin/user-create.php">Create user</a></p>
<form method="post" action="/Tuman/public/logout.php"><input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>"><button type="submit">Sign out</button></form>
<?php tuman_admin_page_end(); ?>
