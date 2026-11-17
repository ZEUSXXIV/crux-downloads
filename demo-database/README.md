# A demo database for Crux: Bitwarden's schema

These files build a real SQL Server database from the open-source [bitwarden/server](https://github.com/bitwarden/server) project's ~550 migration scripts, so you can try Crux with a running database connected: `/drift`, `/deployed`, `/usage`, the SSMS right-click menu, and more.

| File | What it does |
|---|---|
| `build-bitwarden-database.ps1` | Creates the database and applies every Bitwarden migration in order, recording each one the way Bitwarden's own migrator (DbUp) does. |
| `add-test-drift.sql`, `add-test-drift-code.sql` | With `-Drift`: a few changes made by hand afterwards (a column, a key, an index, a procedure, a view), so `/drift` has something known to find. |

Nothing outside the database it creates is changed.

## 1. What you need

- **SQL Server.** The free [LocalDB](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb) is enough (in the SQL Server Express installer, choose **Download Media → LocalDB**). Any other SQL Server you can sign in to with Windows authentication works too.
- **sqlcmd**, the SQL Server command-line tools ([Command Line Utilities for SQL Server](https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility)).
- **Git**.

## 2. Put the files and Bitwarden's repository in one folder

Download the three files above into a folder, for example `C:\crux-demo`. Then clone Bitwarden next to them, into a folder named `bitwarden-server` (the script looks for it there):

```powershell
cd C:\crux-demo
git clone --filter=blob:none https://github.com/bitwarden/server bitwarden-server
```

`--filter=blob:none` keeps the full history, which Crux reads to answer "why", without downloading every old file.

## 3. Build the database

```powershell
powershell -ExecutionPolicy Bypass -File C:\crux-demo\build-bitwarden-database.ps1 -Drift
```

This takes a few minutes. It creates `SchemaMemory_Bitwarden` on `(localdb)\MSSQLLocalDB`, and prints the connection string at the end. A script that fails is listed and skipped, not fatal.

Options:

- `-Server "NAME\INSTANCE"`: another SQL Server instead of LocalDB. Your Windows account needs permission to create databases there.
- `-Database Name`: another database name.
- `-Recreate`: drop and rebuild a database built before.
- Leave out `-Drift` for a database that matches the migrations exactly.

## 4. Point Crux at it

1. In Crux, choose **+** beside Databases, then **On this machine**, and pick `C:\crux-demo\bitwarden-server`. Crux finds the migrations folder itself.
2. Connect the running database: server `(localdb)\MSSQLLocalDB` (or the one you used), database `SchemaMemory_Bitwarden`, **Windows sign-in**.
3. Try `/drift`, `/usage`, `/explain Device`, or ask "Why was InviteRemindersSentCount added to OrganizationUser?". In SSMS, connect to the same server and right-click a table for **Crux → Why does this exist?**
