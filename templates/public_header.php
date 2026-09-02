<?php
declare(strict_types=1);

$pageTitle = $pageTitle ?? 'Tuman — Tuition Management System';
$activePage = $activePage ?? '';
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Tuman is a simple and secure Tuition Management System.">
    <title><?= htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8') ?></title>
    <link rel="stylesheet" href="/Tuman/assets/css/public.css">
</head>
<body>
<header class="site-header">
    <div class="container navigation">
        <a class="brand" href="/Tuman/public/index.php" aria-label="Tuman home">
            <span>Tuman</span><small>Tuition Management System</small>
        </a>
        <nav aria-label="Primary navigation">
            <a href="/Tuman/public/index.php"<?= $activePage === 'home' ? ' aria-current="page"' : '' ?>>Home</a>
            <a href="/Tuman/public/about.php"<?= $activePage === 'about' ? ' aria-current="page"' : '' ?>>About</a>
            <a class="login-link" href="/Tuman/public/login.php"<?= $activePage === 'login' ? ' aria-current="page"' : '' ?>>Login</a>
        </nav>
    </div>
</header>
