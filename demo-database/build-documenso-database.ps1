<#
.SYNOPSIS
Builds a PostgreSQL copy of the documenso/documenso schema to test Crux's database connection.

.DESCRIPTION
Applies every Prisma migration in documenso\packages\prisma\migrations, in folder-name order, to a new
database, and records each one in _prisma_migrations the way Prisma's own `migrate deploy` does: the
migration's folder name, its checksum and when it finished. A migration that fails is reported and
skipped rather than stopping the build, so the result may miss its changes; the summary lists them.

With -Drift, a few changes are then made by hand, outside any migration, so that /drift has something
known to find. They are listed in documenso-drift.sql (a column, a default, an index and a function).

It also tries to switch on pg_stat_statements in the new database, which /usage reads to show which
queries use each table. That needs pg_stat_statements in the server's shared_preload_libraries; if it
is not, the build carries on without it and says so.

Nothing outside the named database is changed. Run it again with -Recreate to start over.

The password, if the server asks for one, is read from the PGPASSWORD environment variable, or psql
asks for it. It is never written to a file.

.EXAMPLE
./build-documenso-database.ps1 -Drift

.EXAMPLE
$env:PGPASSWORD = '...'; ./build-documenso-database.ps1 -Server db.example.com -User crux_demo -Drift
#>
param(
    [string]$Server = 'localhost',
    [int]$Port = 5432,
    [string]$User = 'postgres',
    [string]$Database = 'crux_documenso',
    # The Documenso repository; by default a folder named documenso next to this script.
    [string]$Repository = (Join-Path $PSScriptRoot 'documenso'),
    # The folder with psql.exe, when it is not on PATH, for example 'C:\Program Files\PostgreSQL\17\bin'.
    [string]$PsqlFolder = '',
    [switch]$Recreate,
    [switch]$Drift,
    # Leave out the newest few migrations, as a database that is behind would.
    [int]$SkipLast = 0
)

$ErrorActionPreference = 'Stop'

# psql: the folder given, then PATH, then a standard PostgreSQL install.
$psql = $null
if ($PsqlFolder) {
    $psql = Join-Path $PsqlFolder 'psql.exe'
    if (-not (Test-Path $psql)) { throw "There is no psql.exe in $PsqlFolder." }
}
elseif (Get-Command psql -ErrorAction SilentlyContinue) { $psql = (Get-Command psql).Source }
else {
    $found = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) { $psql = $found.FullName }
}
if (-not $psql) { throw 'psql was not found. Install PostgreSQL (its installer includes psql), or pass -PsqlFolder with the folder that has psql.exe.' }

$migrations = Join-Path $Repository 'packages\prisma\migrations'
if (-not (Test-Path $migrations)) {
    throw "Documenso's migrations were not found at $migrations. Clone it first: git clone --filter=blob:none https://github.com/documenso/documenso `"$Repository`""
}

# Only warnings and errors from the server; and psql's own messages on stderr are read, not treated as failures
# (Windows PowerShell stops on any stderr line otherwise): the exit code says whether it worked.
$env:PGOPTIONS = '-c client_min_messages=warning'

function Invoke-Psql([string]$Query, [string]$On = $Database) {
    $ErrorActionPreference = 'Continue'
    $output = & $psql -h $Server -p $Port -U $User -d $On -v ON_ERROR_STOP=1 -X -q -t -A -c $Query 2>&1
    if ($LASTEXITCODE -ne 0) { throw "psql failed: $output" }
    return $output
}

function Invoke-PsqlFile([string]$Path) {
    $ErrorActionPreference = 'Continue'
    $output = & $psql -h $Server -p $Port -U $User -d $Database -v ON_ERROR_STOP=1 -X -q -1 -f $Path 2>&1
    return [pscustomobject]@{ Ok = ($LASTEXITCODE -eq 0); Output = $output }
}

$quoted = $Database.Replace('"', '""')
$exists = (Invoke-Psql "SELECT count(*) FROM pg_database WHERE datname = '$($Database.Replace("'", "''"))'" 'postgres') -join ''
if ($exists.Trim() -eq '1') {
    if (-not $Recreate) { throw "$Database already exists on $Server. Add -Recreate to drop and rebuild it." }
    Invoke-Psql "DROP DATABASE `"$quoted`" WITH (FORCE)" 'postgres' | Out-Null
}
Invoke-Psql "CREATE DATABASE `"$quoted`"" 'postgres' | Out-Null

# Prisma's own history table, as prisma migrate deploy creates it.
Invoke-Psql @"
CREATE TABLE "_prisma_migrations" (
    "id" VARCHAR(36) PRIMARY KEY NOT NULL,
    "checksum" VARCHAR(64) NOT NULL,
    "finished_at" TIMESTAMPTZ,
    "migration_name" VARCHAR(255) NOT NULL,
    "logs" TEXT,
    "rolled_back_at" TIMESTAMPTZ,
    "started_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "applied_steps_count" INTEGER NOT NULL DEFAULT 0);
"@ | Out-Null

$folders = @(Get-ChildItem $migrations -Directory | Where-Object { $_.Name -match '^\d{14}_' -and (Test-Path (Join-Path $_.FullName 'migration.sql')) } |
    Sort-Object { $_.Name } -Culture ([cultureinfo]::InvariantCulture))
if ($SkipLast -gt 0) { $folders = $folders[0..($folders.Count - $SkipLast - 1)] }
$failed = @()
$started = Get-Date
$sha = [System.Security.Cryptography.SHA256]::Create()
$i = 0
foreach ($folder in $folders) {
    $i++
    Write-Progress -Activity "Applying Documenso migrations to $Database" -Status $folder.Name -PercentComplete (100 * $i / $folders.Count)
    $file = Join-Path $folder.FullName 'migration.sql'
    # Each migration in a transaction of its own, so one that fails leaves nothing half done.
    $run = Invoke-PsqlFile $file
    if (-not $run.Ok) {
        $failed += [pscustomobject]@{ Migration = $folder.Name; Error = (($run.Output | Select-Object -Last 3) -join ' ').Trim() }
        continue
    }
    $checksum = -join ($sha.ComputeHash([System.IO.File]::ReadAllBytes($file)) | ForEach-Object { $_.ToString('x2') })
    Invoke-Psql "INSERT INTO `"_prisma_migrations`" (id, checksum, finished_at, migration_name, applied_steps_count) VALUES (md5(random()::text || clock_timestamp()::text)::uuid::text, '$checksum', now(), '$($folder.Name)', 1)" | Out-Null
}
Write-Progress -Activity "Applying Documenso migrations" -Completed

if ($Drift) {
    $run = Invoke-PsqlFile (Join-Path $PSScriptRoot 'documenso-drift.sql')
    if (-not $run.Ok) { throw "documenso-drift.sql failed: $($run.Output)" }
}

# For /usage: which queries use each table. Works only when the server preloads the extension.
$statements = $true
try { Invoke-Psql 'CREATE EXTENSION IF NOT EXISTS pg_stat_statements; SELECT count(*) FROM pg_stat_statements;' | Out-Null }
catch { $statements = $false }

$minutes = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
Write-Host "Applied $($folders.Count - $failed.Count) of $($folders.Count) migrations to $Database on ${Server}:$Port in $minutes minutes."
if ($failed.Count -gt 0) {
    Write-Host "$($failed.Count) migrations failed and were skipped:"
    $failed | ForEach-Object { Write-Host "  $($_.Migration): $($_.Error)" }
}
if ($Drift) { Write-Host 'Made the hand changes in documenso-drift.sql.' }
if (-not $statements) {
    Write-Host 'pg_stat_statements is not loaded on this server, so /usage will show index and table counts but not queries.'
    Write-Host 'To add it: set shared_preload_libraries = ''pg_stat_statements'' in postgresql.conf, restart PostgreSQL, and run this again with -Recreate.'
}
Write-Host "In Crux, connect with host $Server, port $Port, database $Database, user $User."
Write-Host "Connection string: Host=$Server;Port=$Port;Database=$Database;Username=$User"
