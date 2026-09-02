<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/auth.php';
require_once dirname(__DIR__) . '/includes/csrf.php';

tuman_start_session();
if (tuman_current_user() !== null) {
    header('Location: ' . tuman_role_home($_SESSION['role']));
    exit;
}

$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!tuman_csrf_is_valid($_POST['csrf_token'] ?? null)) {
        $error = 'Your request could not be verified. Please try again.';
    } else {
        $username = trim((string) ($_POST['username'] ?? ''));
        $password = (string) ($_POST['password'] ?? '');
        try {
            $identity = tuman_authenticate($username, $password);
            if ($identity !== null) {
                tuman_login($identity);
                header('Location: ' . tuman_role_home($identity['role']));
                exit;
            }
            $error = 'Invalid username or password.';
        } catch (RuntimeException $exception) {
            $error = 'Unable to sign in right now. Please try again later.';
        }
    }
}
?>
<?php
$pageTitle = 'Sign in — Tuman';
$activePage = 'login';
require_once dirname(__DIR__) . '/templates/public_header.php';
?>
<main class="section">
    <div class="container content">
    <h1>Sign in to Tuman</h1>
    <?php if ($error !== null): ?><p role="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?>
    <form method="post" action="">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars(tuman_csrf_token(), ENT_QUOTES, 'UTF-8') ?>">
        <p><label>Username <input name="username" maxlength="50" required autocomplete="username"></label></p>
        <p><label>Password <input type="password" name="password" required autocomplete="current-password"></label></p>
        <p><button type="submit">Sign in</button></p>
    </form>
    </div>
</main>
<?php require_once dirname(__DIR__) . '/templates/public_footer.php'; ?>
