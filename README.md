# Crux — downloads

This repository only hosts the **public installers** for Crux, the desktop app that explains why and when each table and column in your SQL Server database came to be.

Crux's source is kept private. Its **Build desktop installer** workflow publishes each installer here as a GitHub release, so these links always fetch the newest full release:

- Windows (x64): [`releases/latest/download/CruxSetup.exe`](../../releases/latest/download/CruxSetup.exe)
- Windows (Arm64): [`releases/latest/download/CruxSetup-arm64.exe`](../../releases/latest/download/CruxSetup-arm64.exe)

Preview builds are marked **Pre-release** and are listed on the [releases page](../../releases), not behind the links above.

## Installing

Run the installer. Crux installs for your Windows user only, so it needs no administrator rights, and adds itself to the Start menu and to **Installed apps**, where you can uninstall it.

The app is not signed yet, so if Windows SmartScreen warns, choose **More info**, then **Run anyway**. Crux needs [Git](https://git-scm.com/download/win) and the Microsoft Edge WebView2 Runtime, which Windows 11 and recent Windows 10 already have.
