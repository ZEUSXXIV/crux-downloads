# What's new in Crux

## 0.4.0 (preview) — 18 November 2026

Crux connects to a running PostgreSQL database. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.4.0)

- **Connect a PostgreSQL database** with host, port, user, password and SSL mode, or a `postgresql://` address. Read only, and any user that can connect is enough.
- **`/drift`** compares it with its migrations, allowing for how PostgreSQL rewrites types, defaults, index expressions and views. Documenso, Mattermost and Conductor, built from their migrations, show no differences.
- **`/deployed`** from Flyway's, Prisma's or golang-migrate's history table, and **`/usage`** from PostgreSQL's statistics and `pg_stat_statements`, with the quietest hours once Crux has a week of hourly readings.
- **Lock and rewrite warnings for PostgreSQL** in `/pr` and Check this script, sized against your tables: `CONCURRENTLY`, type changes, defaults, `SET NOT NULL`, `NOT VALID`, `lock_timeout`.
- **A Documenso demo database** for PostgreSQL in [demo-database](demo-database).
- `crux report /drift` (or any report) prints one report from the command line, without a model.

## 0.3.1 (preview) — 18 November 2026

PostgreSQL support checked against real databases. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.3.1)

- **Matches real PostgreSQL databases.** Documenso's, Mattermost's and Conductor's migrations were run on PostgreSQL 17.7: every table, column, type, nullability, index and foreign key Crux works out now matches the database.
- **Fixed on the way:** `IF NOT EXISTS` does nothing when the object is there; unnamed keys and indexes get PostgreSQL's own names; primary key columns are NOT NULL; `DEFAULT NULL` is no default.
- **A tag for each database's kind**, **MSSQL** or **PG**, in the sidebar and at the top of a chat.

## 0.3.0 (preview) — 18 November 2026

Crux reads PostgreSQL migrations. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.3.0)

- **PostgreSQL migrations, read with PostgreSQL's own parser.** Why and when, `/impact` (including PL/pgSQL functions and triggers), pull request and script checks, the reports and MCP all work as for SQL Server. Checked against more than 1,000 real migrations without a parse error.
- **Flyway, Prisma and golang-migrate layouts**, plus `COMMENT ON` descriptions, `DO` blocks and `SET search_path`.
- **Crux works out whether a repository is SQL Server or PostgreSQL**, says which on the database's page, and lets you change it.
- Not yet: connecting to a running PostgreSQL database (`/drift`, `/usage`, sizes).

## 0.2.1 — 17 November 2026

A fix for Crux in SSMS 22; update if you added Crux to SSMS with 0.2.0. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.2.1)

- **Works on every SSMS 22 update.** 0.2.0's SSMS extension was tied to the exact SSMS build it was made with, so on newer SSMS 22 releases its menu could not load. It now uses whatever SSMS is installed.
- **Can no longer take SSMS down.** If something gets in Crux's way, that Crux feature switches off and the reason goes to `%LOCALAPPDATA%\Crux\ssms.log`, while SSMS carries on.

## 0.2.0 — 17 November 2026

Crux comes to the tools you already work in. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.2.0)

**Crux in SSMS 22**
- Right-click a table, column, view, procedure or function in Object Explorer: **Crux → Why does this exist? / What depends on it? / How is it used?**
- Right-click in a query window: **Crux: Check this script** shows what a script would break before you run it, such as procedures still using a column it drops, risky column changes, and statements that would lock a big table, with the quietest time to run them. Nothing is run.
- Answers open in a docked Crux panel that follows SSMS's theme. Crux works out which of your databases the connection is, and asks once when it can't tell.
- Setup offers **Add Crux to SSMS 22**.

**Crux in AI tools (MCP)**
- Claude Code, Claude Desktop, VS Code and Cursor can use Crux as an MCP server (`Crux.exe mcp`); **Settings → Use Crux in AI tools** shows the setup.
- Read-only tools with links to every source, including `check_script` for checking a migration an agent wrote. A prompt for every report. Crux picks the database from your project, the one you last opened, or the table you named.

**Better pull request checks**
- A connected database is compared with the base branch as it is now, so changes deployed after a branch started, or a script merged under another name, aren't reported as hand changes. Index warnings name only the index that changed.

**One place for your data**
- Data now lives in `C:\Users\<you>\.crux`, the same however Crux is started. Earlier data is brought over automatically.

## 0.1.0 — 16 November 2026

The first public build: the Crux desktop app, with chats per database, ready-made reports (`/explain`, `/impact`, `/pr`, `/drift`, `/usage` and more), a guided tour, Markdown pull requests and commits, a built-in terminal and file viewer, and an installer. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.1.0)
