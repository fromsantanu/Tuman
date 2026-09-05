# Tuman Data Restoration Guide

This guide restores the complete Tuman MySQL database from a backup created by the Phase 21 backup feature.

> **Warning:** A full restore permanently replaces the current `tuman` database with the contents of the selected backup. Any records created after that backup will be lost. Create a new backup of the current database before proceeding whenever possible.

## What you need

- Access to the Tuman server.
- A Tuman backup archive, such as `C:\TumanBackups\tuman-YYYYMMDD-HHMMSS-xxxxxxxxxxxx.sql.gz`.
- A MySQL Administrator account with permission to create and drop the `tuman` database. The normal application account (`tuman_app`) may not have sufficient permissions.
- The installed MySQL 8 command-line client:

  `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`

## Before restoring

1. Tell users that Tuman will briefly be unavailable.
2. Stop Apache, or otherwise prevent Tuman from receiving requests. This prevents writes while the database is being replaced.
3. Create a fresh backup of the current database if it is still accessible:

   ```powershell
   cd C:\xampp\htdocs\Tuman
   php bin\backup-database.php
   ```

4. Confirm the filename and date of the backup you intend to restore. Do not choose a backup unless you understand that it becomes the new source of truth.

## Restore the complete database

The following example restores the backup `tuman-20260905-164421-a5eef240ea08.sql.gz`. Replace that filename with the backup you need.

### 1. Extract the backup archive

Open PowerShell and run:

```powershell
$in = [System.IO.File]::OpenRead('C:\TumanBackups\tuman-20260905-164421-a5eef240ea08.sql.gz')
$gzip = [System.IO.Compression.GzipStream]::new($in, [System.IO.Compression.CompressionMode]::Decompress)
$out = [System.IO.File]::Create('C:\TumanBackups\tuman-restore.sql')
$gzip.CopyTo($out)
$out.Close()
$gzip.Close()
$in.Close()
```

This creates an uncompressed SQL file at `C:\TumanBackups\tuman-restore.sql`. Treat it as sensitive data.

### 2. Replace the existing database

Run the following command. It prompts for the MySQL Administrator password; enter it only at the prompt. Never add the password to the command itself.

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -h 127.0.0.1 -P 3306 -u root -p -e "DROP DATABASE IF EXISTS tuman; CREATE DATABASE tuman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

If the MySQL Administrator account is not `root`, replace `root` with the correct account name.

### 3. Import the backup

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -h 127.0.0.1 -P 3306 -u root -p < 'C:\TumanBackups\tuman-restore.sql'
```

Wait for the command to finish. It normally returns to PowerShell without an error message when the import succeeds.

## Verify the restoration

Run this read-only check:

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -h 127.0.0.1 -P 3306 -u root -p -e "USE tuman; SHOW TABLES; SELECT COUNT(*) AS users FROM tmn_users;"
```

Then:

1. Start Apache/Tuman again.
2. Open the Tuman login page.
3. Sign in with a known Administrator account.
4. Check expected users, invoices, payments, and the **Backups and retention** page.

The backup represents the database at its creation time. Backup-run history and any records created later will only be present if they existed in the selected archive.

## After successful restoration

Delete the temporary uncompressed SQL file once verification is complete:

```powershell
Remove-Item -LiteralPath 'C:\TumanBackups\tuman-restore.sql'
```

Keep the original `.sql.gz` backup archive according to the retention policy. It is compressed but still contains sensitive database data, so ensure the backup folder remains protected from ordinary users and web access.

## Troubleshooting

| Problem | Likely cause and action |
| --- | --- |
| `Access denied` | Use a MySQL Administrator account with database creation and deletion permissions. |
| `mysql.exe` cannot be found | Confirm that MySQL 8 is installed at the path in this guide, or update the command to the installed MySQL client path. |
| Import reports a connection error | Check that the MySQL service is running and that host `127.0.0.1` and port `3306` match the Tuman `.env` configuration. |
| The restored data is not the expected version | Stop and select the correct timestamped backup. Do not continue making changes until the intended backup is identified. |
| Tuman cannot connect after restore | Confirm that the application database name, host, port, and application-user permissions in `.env` are still valid. |
