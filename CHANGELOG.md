# What's new in Crux

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
