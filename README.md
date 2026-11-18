# Crux — downloads

This repository only hosts the **public installers** for Crux, the desktop app that explains why and when each table and column in your SQL Server database (or PostgreSQL, in the [0.4.0 preview](https://github.com/ZEUSXXIV/crux-downloads/releases/tag/v0.4.0)) came to be, citing the migrations, commits and pull requests behind every answer.

**Download:** [`CruxSetup.exe`](../../releases/latest/download/CruxSetup.exe) for Windows (x64). This link always fetches the newest full release. Older versions, previews and any Arm64 builds are on the [releases page](../../releases).

What's in each version: [CHANGELOG.md](CHANGELOG.md).

**See what Crux does:** [the Crux deck online](https://zeusxxiv.github.io/crux-downloads/deck/), 19 slides on the problems it solves, how it works, and each feature, with real output. Use the arrow keys, or **Present** (P) for a presenter view with speaker notes. To keep a copy or present offline: [PowerPoint](../../raw/main/deck/Crux-deck.pptx) (with speaker notes) or [PDF](../../raw/main/deck/Crux-deck.pdf).

**Try it with a real database:** [demo-database](demo-database) builds Bitwarden's schema from its ~550 migration scripts on SQL Server LocalDB, or Documenso's from its 169 migrations on PostgreSQL, ready for Crux to connect to.

Crux works in its own window, and also:

- **In SSMS 22:** right-click a table or column in Object Explorer to ask why it exists, or right-click a query to check what it would break before you run it. Setup offers to add it.
- **In AI tools:** Claude Code, Claude Desktop, VS Code and Cursor can use Crux as an MCP server. The app's **Settings → Use Crux in AI tools** shows how.

Crux's source is kept private; installers are published here as GitHub releases.

## Installing

Run the installer. Crux installs for your Windows user only, so it needs no administrator rights, and adds itself to the Start menu and to **Installed apps**, where you can uninstall it. Adding Crux to SSMS asks for Windows' permission once, because SSMS only loads extensions from its own folder under Program Files.

The app is not signed yet, so if Windows SmartScreen warns, choose **More info**, then **Run anyway**. Crux needs [Git](https://git-scm.com/download/win) and the Microsoft Edge WebView2 Runtime, which Windows 11 and recent Windows 10 already have.
