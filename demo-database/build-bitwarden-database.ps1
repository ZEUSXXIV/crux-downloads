<#
.SYNOPSIS
Builds a SQL Server copy of the bitwarden/server schema to test Crux's database connection.

.DESCRIPTION
Applies every script in samples/bitwarden-server/util/Migrator/DbScripts, in file-name order, to a
new database, and records each one in [dbo].[Migration] the way bitwarden's own migrator (DbUp)
does: the script's resource name and the time it was applied. A script that fails is reported and
skipped rather than stopping the build, so the result may miss its changes; the summary lists them.

With -Drift, a few changes are then made by hand, outside any migration, so that /drift has
something known to find. They are listed in add-test-drift.sql (tables, columns and keys) and
add-test-drift-code.sql (indexes, a default, procedures and a view).

Nothing outside the named database is changed. Run it again with -Recreate to start over.

.EXAMPLE
./build-bitwarden-database.ps1 -Drift
#>
param(
    [string]$Server = '(localdb)\MSSQLLocalDB',
    [string]$Database = 'SchemaMemory_Bitwarden',
    [switch]$Recreate,
    [switch]$Drift,
    # Leave out the newest few scripts, as a database that is behind would.
    [int]$SkipLast = 0,
    # A script that is not in the repository, run and recorded after the others, as if applied from another branch.
    [string]$Foreign = ''
)

$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot 'bitwarden-server\util\Migrator\DbScripts'
# sqlcmd is run with -C (trust the server's certificate): newer SQL Server tools encrypt by default and reject the
# self-signed certificate LocalDB and a fresh SQL Server use, with "the certificate chain was issued by an authority
# that is not trusted".
if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) { throw 'sqlcmd was not found. Install the SQL Server command line tools.' }

function Invoke-Sql([string]$Query, [string]$On = $Database) {
    $output = & sqlcmd -C -S $Server -d $On -b -I -x -h -1 -W -Q "SET NOCOUNT ON; $Query" 2>&1
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed: $output" }
    return $output
}

$exists = (Invoke-Sql "SELECT COUNT(*) FROM sys.databases WHERE name = N'$Database'" 'master') -join ''
if ($exists.Trim() -eq '1') {
    if (-not $Recreate) { throw "$Database already exists on $Server. Add -Recreate to drop and rebuild it." }
    Invoke-Sql "ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$Database];" 'master' | Out-Null
}
Invoke-Sql "CREATE DATABASE [$Database];" 'master' | Out-Null
Invoke-Sql @"
CREATE TABLE [dbo].[Migration] (
    [Id] INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Migration_Id] PRIMARY KEY,
    [ScriptName] NVARCHAR(255) NOT NULL,
    [Applied] DATETIME NOT NULL);
"@ | Out-Null

# DbUp runs embedded scripts in ordinal order of their resource names, which here is file-name order.
$files = @(Get-ChildItem $scripts -Filter *.sql | Sort-Object { $_.Name } -Culture ([cultureinfo]::InvariantCulture))
if ($SkipLast -gt 0) { $files = $files[0..($files.Count - $SkipLast - 1)] }
$failed = @()
$started = Get-Date
$copy = Join-Path ([System.IO.Path]::GetTempPath()) "crux-migration.sql"
$i = 0
foreach ($file in $files) {
    $i++
    Write-Progress -Activity "Applying bitwarden migrations to $Database" -Status $file.Name -PercentComplete (100 * $i / $files.Count)
    # DbUp accepts "GO;", an indented "GO" and a "GO;" at the end of a statement's line as batch separators;
    # sqlcmd needs a bare GO on a line of its own, so those scripts run from a copy written that way.
    $script = $file.FullName
    $text = [System.IO.File]::ReadAllText($script)
    if ($text -match '(?m)^[ \t]+GO[ \t]*;?[ \t]*\r?$|(?m)^[ \t]*GO[ \t]*;[ \t]*\r?$|(?m)\S[ \t]+GO[ \t]*;[ \t]*\r?$') {
        $fixed = $text -replace '(?m)^(.*\S)[ \t]+GO[ \t]*;[ \t]*(\r?)$', "`$1`$2`nGO`$2"
        $fixed = $fixed -replace '(?m)^[ \t]*GO[ \t]*;?[ \t]*(\r?)$', 'GO$1'
        [System.IO.File]::WriteAllText($copy, $fixed, [System.Text.UTF8Encoding]::new($true))
        $script = $copy
    }
    $output = & sqlcmd -C -S $Server -d $Database -b -I -x -i $script 2>&1
    if ($LASTEXITCODE -ne 0) {
        $failed += [pscustomobject]@{ Script = $file.Name; Error = (($output | Select-Object -Last 3) -join ' ').Trim() }
        continue
    }
    $name = "Bit.Migrator.DbScripts.$($file.Name)".Replace("'", "''")
    Invoke-Sql "INSERT INTO [dbo].[Migration] ([ScriptName], [Applied]) VALUES (N'$name', SYSUTCDATETIME());" | Out-Null
}
Write-Progress -Activity "Applying bitwarden migrations" -Completed

if ($Foreign) {
    $output = & sqlcmd -C -S $Server -d $Database -b -I -x -i $Foreign 2>&1
    if ($LASTEXITCODE -ne 0) { throw "$Foreign failed: $output" }
    $name = "Bit.Migrator.DbScripts.$([System.IO.Path]::GetFileName($Foreign))".Replace("'", "''")
    Invoke-Sql "INSERT INTO [dbo].[Migration] ([ScriptName], [Applied]) VALUES (N'$name', SYSUTCDATETIME());" | Out-Null
}

if ($Drift) {
    foreach ($name in 'add-test-drift.sql', 'add-test-drift-code.sql') {
        $output = & sqlcmd -C -S $Server -d $Database -b -I -x -i (Join-Path $PSScriptRoot $name) 2>&1
        if ($LASTEXITCODE -ne 0) { throw "$name failed: $output" }
    }
}

$minutes = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
Write-Host "Applied $($files.Count - $failed.Count) of $($files.Count) scripts to $Database on $Server in $minutes minutes."
if ($failed.Count -gt 0) {
    Write-Host "$($failed.Count) scripts failed and were skipped:"
    $failed | ForEach-Object { Write-Host "  $($_.Script): $($_.Error)" }
}
if ($Drift) { Write-Host 'Made the hand changes in add-test-drift.sql and add-test-drift-code.sql.' }
Write-Host "Connection string: Server=$Server;Database=$Database;Integrated Security=true;TrustServerCertificate=true"
