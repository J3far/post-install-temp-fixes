/**************************************
* NZFUH QESTNET Upgrade
* Pre-Upgrade Script
*
* Run this script before starting QESTNET Upgrade
* to modify or remove defaults, indexes and data entries that
* are known to cause errors.
*
* Run the post upgrade script after upgrading to restore
* removed objects.
****************************************/

-- Remove default on UserID in SessionConnections
DECLARE @default sysname
SELECT @default = object_name(cdefault) FROM syscolumns
 WHERE id = object_id('[dbo].[SessionConnections]') AND name = 'UserID'
 IF @default IS NOT NULL
	EXEC ('ALTER TABLE [dbo].[SessionConnections] DROP CONSTRAINT ' + @default)
GO

-- Remove statistic on SessionConnections
IF EXISTS (SELECT name FROM sys.stats WHERE name = N'redrock14nov__stat_1255727576_3_2' AND object_id = OBJECT_ID(N'[dbo].SessionConnections'))
	DROP STATISTICS [dbo].[SessionConnections].[redrock14nov__stat_1255727576_3_2]
GO

--Remove index on SpecificationRecords
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_SpecificationID' AND object_id = OBJECT_ID(N'[dbo].[SpecificationRecords]'))
	DROP INDEX [IX_SpecificationID] ON [dbo].[SpecificationRecords]
GO

--Remove indexes on Equipment
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'redrock14nov__index_qestReportMapping_c_5_1166835419__K3_K4_K6' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))	
	DROP INDEX [redrock14nov__index_qestReportMapping_c_5_1166835419__K3_K4_K6] ON [dbo].[qestReportMapping];	
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_qestReportMapping_ReportQestID' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	DROP INDEX [IX_qestReportMapping_ReportQestID] ON [dbo].[qestReportMapping];
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_qestReportMapping_ReportQestUniqueID' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	DROP INDEX [IX_qestReportMapping_ReportQestUniqueID] ON [dbo].[qestReportMapping];
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_qestReportMapping_TestQestUniqueID' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	DROP INDEX [IX_qestReportMapping_TestQestUniqueID] ON [dbo].[qestReportMapping];
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'redrock14nov__index_qestReportMapping_5_1166835419__K4_K5_K3_6' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	DROP INDEX [redrock14nov__index_qestReportMapping_5_1166835419__K4_K5_K3_6] ON [dbo].[qestReportMapping];
GO

--Remove statistic on qestReportMapping
IF EXISTS (SELECT name FROM sys.stats WHERE name = N'redrock14nov__stat_1166835419_4_6_3' AND object_id = OBJECT_ID(N'[dbo].qestReportMapping'))
	DROP STATISTICS [dbo].[qestReportMapping].[redrock14nov__stat_1166835419_4_6_3]
GO

--Replace null lab no. with 0 (global) for clients
UPDATE [dbo].[ListClient] SET QestOwnerLabNo = 0 where QestOwnerLabNo is null
GO

--Remove indexes on Equipment
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS415aecd5-20b8-4105-b86c-78b011f30b20' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	DROP INDEX [ix_Equipment_RS415aecd5-20b8-4105-b86c-78b011f30b20] ON [dbo].[Equipment];	
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS7a89c04e-4209-44ef-95cb-51483fecc6ec' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	DROP INDEX [ix_Equipment_RS7a89c04e-4209-44ef-95cb-51483fecc6ec] ON [dbo].[Equipment];
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS9d1a3a2f-3262-4110-b13d-b56921cdc6f2' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	DROP INDEX [ix_Equipment_RS9d1a3a2f-3262-4110-b13d-b56921cdc6f2] ON [dbo].[Equipment];
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RSf4ecf10e-d27c-4641-9888-6b497cfa0787' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	DROP INDEX [ix_Equipment_RSf4ecf10e-d27c-4641-9888-6b497cfa0787] ON [dbo].[Equipment];
GO

-- Remove invalid qestReverseLookup entries
DELETE FROM qestReverseLookup WHERE QestID not in (SELECT QestID FROM qestObjects)

-- update the null QESTIds 
update DocumentWheelTrackingSingle set QestID = 111275 where QestID is null