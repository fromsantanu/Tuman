<?php
declare(strict_types=1);
$pageTitle = 'About Tuman';
$activePage = 'about';
require_once dirname(__DIR__) . '/templates/public_header.php';
?>
<main class="section">
    <div class="container content">
        <p class="eyebrow">About Tuman</p>
        <h1>Simple tuition management, built with care.</h1>
        <p>Tuman is a Tuition Management System for individual teachers and small tuition organisations. Its goal is to make routine information easier to organise without making the application difficult to understand or use.</p>
        <h2>Who it is for</h2>
        <p>Administrators will manage accounts and system information. Teachers will work with their assigned students. Students will have secure access to their own permitted information.</p>
        <h2>What Tuman is designed to support</h2>
        <p>As development continues, Tuman will support student relationships, attendance, billing rules, invoices, and payment records. Each feature is introduced in phases so the system remains reliable and approachable.</p>
        <h2>A secure, understandable foundation</h2>
        <p>Tuman uses PHP and MySQL with PDO prepared statements, secure password hashing, PHP sessions, and server-side access checks. This keeps the project practical for real use while making its design clear for students learning software development.</p>
    </div>
</main>
<?php require_once dirname(__DIR__) . '/templates/public_footer.php'; ?>
