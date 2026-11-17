-- More changes made by hand, outside any migration: indexes, a default, procedures and a view.
-- build-bitwarden-database.ps1 -Drift runs this after add-test-drift.sql. Each is a kind of drift
-- seen in real databases: a hotfixed procedure, a missing index, a tuning index nobody recorded.

-- A procedure hotfixed in place: the migrations' version has no Active filter.
ALTER PROCEDURE [dbo].[Device_ReadById]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        *
    FROM
        [dbo].[DeviceView]
    WHERE
        [Id] = @Id
        AND [Active] = 1
END
GO

-- A procedure created by hand, for a support task.
CREATE PROCEDURE [dbo].[Support_ExportOrganization]
    @OrganizationId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [dbo].[SupportExport] ([Id], [OrganizationId], [ExportedAt])
    SELECT ISNULL(MAX([Id]), 0) + 1, @OrganizationId, SYSUTCDATETIME()
    FROM [dbo].[SupportExport]
END
GO

-- A view dropped by hand.
DROP VIEW [dbo].[OrganizationConnectionView];
GO

-- A tuning index added by hand.
CREATE NONCLUSTERED INDEX [IX_Device_PushToken] ON [dbo].[Device] ([PushToken]);
GO

-- An index the migrations created, dropped by hand.
DROP INDEX [IX_Cipher_DeletedDate] ON [dbo].[Cipher];
GO

-- An index rebuilt by hand with an extra included column.
CREATE NONCLUSTERED INDEX [IX_Send_DeletionDate] ON [dbo].[Send] ([DeletionDate]) INCLUDE ([UserId]) WITH (DROP_EXISTING = ON);
GO

-- A default changed by hand: the migrations say new devices are active.
ALTER TABLE [dbo].[Device] DROP CONSTRAINT [DF_Device_Active];
ALTER TABLE [dbo].[Device] ADD CONSTRAINT [DF_Device_Active] DEFAULT (0) FOR [Active];
GO
