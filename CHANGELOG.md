# What's new in Crux

## 0.5.1 — 20 November 2026

The chat checks its own SQL, plans before it writes, and shows query plans at production size. If you have 0.5.0, the **Update** button in Crux's title bar installs this one. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.5.1)

- **Checked fixes.** SQL the chat writes is checked before you see it: names your migrations don't have, errors SQL Server gives in the sandbox, and code a migration breaks go back to the model with the real columns. The answer shows the corrected script, marked "Corrected before it was shown".
- **Plan mode.** An **Ask | Plan** switch by the chat box. Describe a schema change and get a plan first: the steps, what each touches, risks and how to back out. **Generate migrations** writes one migration per step, checked and run together in order in the sandbox; **Save all as migrations** writes them with your repository's naming.
- **Plans at production size.** With a database connected, the sandbox's tables are given the real row counts inside the rolled-back run, and SQL Server's estimated plans show what a query would read, flag big scans, and say whether a new index is used.

## 0.5.0 — 20 November 2026

The first full release since 0.2.1, with everything from the 0.3 and 0.4 previews. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.5.0)

- **A sandbox that runs your scripts for real.** Crux builds a database of its own from your migrations (on LocalDB or a SQL Server you choose), runs each script you check in it and rolls it back. It reports SQL Server's errors, every view and procedure that no longer compiles, and the schema before and after. It is fenced: only Crux's own marked database, a user with no login, scripts that reach outside refused, every run rolled back.
- **Crux updates itself.** An **Update** button in the title bar installs a newer Crux and reopens it. This is the last version you install by hand.
- **From the previews:** PostgreSQL; quick look, history on hover, the status bar and "why did my query fail" in SSMS 22; checked queries and migrations in the chat; attached files; context and Compact.

## 0.4.3 (preview) — 19 November 2026

Crux on SSMS's status bar, and why a query failed. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.4.3)

- **Crux on the status bar** follows what you select in a query (`Crux · Organization · 2017 · used by 45`); a click opens the quick look.
- **⚠ Crux: why?** When a query fails on a missing table or column, Crux says what happened to it: renamed (to what, in which script), dropped, in a migration not run here, or never there, with the nearest names. **Copy fixed query** and **Ask Crux to fix it**.
- **Queries the chat writes are checked** against the migrations: a table or column they don't have is flagged under the answer.
- A query window's own connection and database are used, including one picked from SSMS's drop-down.

## 0.4.2 (preview) — 19 November 2026

Crux in SSMS without opening the panel. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.4.2)

- **Includes Crux's SSMS extension again.** The previews since 0.3.0 were built without it; install this one if you added Crux to SSMS.
- **Quick look:** Crux → Quick look in Object Explorer, or Ctrl+K, Ctrl+Q on a name in a query, opens a small card in SSMS's colours: type, when it was made and changed with its pull request, size, and what uses it.
- **History on hover** over names in a query, with table aliases and bare column names understood. Turn it off from the query editor's menu.
- **Use SSMS's connection:** with Windows sign-in, one click connects Crux to the database, read only, for sizes, `/usage` and `/drift`.
- **Fixed:** in a repository that moved or copied its migrations folder, scripts said they were written by the move. Crux now finds the commit that really wrote them.

## 0.4.1 (preview) — 18 November 2026

The chat writes and checks SQL, takes attached files, and handles long conversations. A preview: 0.2.1 stays the main download. [Download](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.4.1)

- **Scripts the model writes are checked.** Each query or migration is shown under the answer to copy; a migration is named your repository's way, with **Save as a migration…**, and Crux checks it as written. Nothing is run.
- **On PostgreSQL, a missing pair of double quotes is an error:** `Recipient` for a table created as `"Recipient"` would fail.
- **Attach text files** (scripts, logs, errors, query plans) with the paperclip, by dropping or by pasting. Attached scripts are checked before the model answers.
- **Context** in the side panel shows how much of the model's context a chat uses, with a limit per model. Long chats leave out old lookups past 80%, and Claude's requests are cached.
- **Compact**, or `/compact`, summarises the chat so far and carries on from the summary.
- **`/deployed` on PostgreSQL** lists scripts not run yet, and failed and rolled-back runs.
- A tidier side panel.

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
