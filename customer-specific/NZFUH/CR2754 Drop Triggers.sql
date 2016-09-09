IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_BSGMethod]'))
	DROP TRIGGER dbo.TR_BSGMethod;
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Trigger_Update117122]'))
	DROP TRIGGER dbo.Trigger_Update117122;
GO