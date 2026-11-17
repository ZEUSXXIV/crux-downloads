-- Changes made by hand, outside any migration, so that Crux's /drift has known answers.
-- build-bitwarden-database.ps1 -Drift runs this after the migrations. Each one is a kind of drift
-- seen in real databases: a hotfix column, a side table, a widened or relaxed column, a dropped key,
-- and a script that was applied from somewhere other than the repository.

-- A column added by hand: /drift lists it as added by no migration.
ALTER TABLE [dbo].[Organization] ADD [HotfixNote] NVARCHAR(200) NULL;
GO

-- A table created by hand, with its own foreign key: listed once, as a table created by no migration.
CREATE TABLE [dbo].[SupportExport] (
    [Id] INT NOT NULL CONSTRAINT [PK_SupportExport] PRIMARY KEY,
    [OrganizationId] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [FK_SupportExport_Organization] REFERENCES [dbo].[Organization] ([Id]),
    [ExportedAt] DATETIME2(7) NOT NULL);
GO

-- A column widened by hand: the migrations say NVARCHAR(255).
ALTER TABLE [dbo].[Device] ALTER COLUMN [PushToken] NVARCHAR(500) NULL;
GO

-- A column made nullable by hand: the migrations say NOT NULL.
ALTER TABLE [dbo].[Device] ALTER COLUMN [Name] NVARCHAR(50) NULL;
GO

-- A foreign key the migrations created, dropped by hand.
ALTER TABLE [dbo].[AuthRequest] DROP CONSTRAINT [FK_AuthRequest_ResponseDevice];
GO

-- A script recorded as applied that is not in the repository, for example run from another branch.
INSERT INTO [dbo].[Migration] ([ScriptName], [Applied])
VALUES (N'Bit.Migrator.DbScripts.2026-11-10_00_HotfixDeviceIndex.sql', '2026-11-10T09:30:00');
GO
