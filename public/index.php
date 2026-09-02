<?php
declare(strict_types=1);
$pageTitle = 'Tuman — Tuition Management System';
$activePage = 'home';
require_once dirname(__DIR__) . '/templates/public_header.php';
?>
<main>
    <section class="hero">
        <div class="container">
            <p class="eyebrow">Tuition Management System</p>
            <h1>Bring clarity to everyday tuition management.</h1>
            <p>Tuman is being built for teachers and small tuition organisations that want a simple, secure way to organise their work and keep everyone informed.</p>
            <a class="button" href="/Tuman/public/login.php">Sign in to Tuman</a>
        </div>
    </section>
    <section class="section">
        <div class="container">
            <div class="section-heading">
                <h2>Designed around the people who use it</h2>
                <p>Tuman’s planned tools are focused on clear information, practical record keeping, and secure access for each role.</p>
            </div>
            <div class="cards">
                <article class="card"><h3>Administrators</h3><p>Maintain user accounts and oversee the system with appropriate administrative controls.</p></article>
                <article class="card"><h3>Teachers</h3><p>Manage assigned students, daywise tuition records, responsibilities, and future billing work.</p></article>
                <article class="card"><h3>Students</h3><p>Access only their own authorised information, including future attendance and invoice views.</p></article>
            </div>
        </div>
    </section>
</main>
<?php require_once dirname(__DIR__) . '/templates/public_footer.php'; ?>
