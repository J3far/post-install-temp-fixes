/**************************************
* NZFUH QESTNET Upgrade
* Post-Upgrade Script
*
* Run this script after the QESTNET Upgrade
* process has finished successfully to restore
* the objects removed by the NZFUH Pre-Upgrade script 
* that are not restored during the upgrade process
****************************************/

-- User-defined statistics
IF NOT EXISTS (SELECT name FROM sys.stats WHERE name = N'redrock14nov__stat_1255727576_3_2' AND object_id = OBJECT_ID(N'[dbo].SessionConnections'))
	CREATE STATISTICS [redrock14nov__stat_1255727576_3_2] ON [dbo].[SessionConnections]([UserID], [ConnectionName])
GO
IF NOT EXISTS (SELECT name FROM sys.stats WHERE name = N'redrock14nov__stat_1166835419_4_6_3' AND object_id = OBJECT_ID(N'[dbo].qestReportMapping'))
	CREATE STATISTICS [redrock14nov__stat_1166835419_4_6_3] ON [dbo].[qestReportMapping]([TestQestUniqueID], [Mapping], [TestQestID])
GO

-- User-defined indexes	
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'redrock14nov__index_qestReportMapping_c_5_1166835419__K3_K4_K6' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	CREATE NONCLUSTERED INDEX [redrock14nov__index_qestReportMapping_c_5_1166835419__K3_K4_K6] ON [dbo].[qestReportMapping]
	(
		[TestQestID] ASC,
		[TestQestUniqueID] ASC,
		[Mapping] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'redrock14nov__index_qestReportMapping_5_1166835419__K4_K5_K3_6' AND object_id = OBJECT_ID(N'[dbo].[qestReportMapping]'))
	CREATE NONCLUSTERED INDEX [redrock14nov__index_qestReportMapping_5_1166835419__K4_K5_K3_6] ON [dbo].[qestReportMapping]
	(
		[TestQestUniqueID] ASC,
		[Registration] ASC,
		[TestQestID] ASC
	)
	INCLUDE ( 	[Mapping]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS415aecd5-20b8-4105-b86c-78b011f30b20' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	CREATE NONCLUSTERED INDEX [ix_Equipment_RS415aecd5-20b8-4105-b86c-78b011f30b20] ON [dbo].[Equipment]
	(
		[Calibration4DismissAdvice] ASC,
		[QestOwnerLabNo] ASC,
		[NotInService] ASC,
		[NextCalibration4AdviseDate] ASC
	)
	INCLUDE ( 	[QestID],
		[QestUniqueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS7a89c04e-4209-44ef-95cb-51483fecc6ec' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	CREATE NONCLUSTERED INDEX [ix_Equipment_RS7a89c04e-4209-44ef-95cb-51483fecc6ec] ON [dbo].[Equipment]
	(
		[CalibrationDismissAdvice] ASC,
		[QestOwnerLabNo] ASC,
		[NotInService] ASC,
		[NextCalibrationAdviseDate] ASC
	)
	INCLUDE ( 	[QestID],
		[QestUniqueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RS9d1a3a2f-3262-4110-b13d-b56921cdc6f2' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	CREATE NONCLUSTERED INDEX [ix_Equipment_RS9d1a3a2f-3262-4110-b13d-b56921cdc6f2] ON [dbo].[Equipment]
	(
		[Calibration3DismissAdvice] ASC,
		[QestOwnerLabNo] ASC,
		[NotInService] ASC,
		[NextCalibration3AdviseDate] ASC
	)
	INCLUDE ( 	[QestID],
		[QestUniqueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'ix_Equipment_RSf4ecf10e-d27c-4641-9888-6b497cfa0787' AND object_id = OBJECT_ID(N'[dbo].[Equipment]'))
	CREATE NONCLUSTERED INDEX [ix_Equipment_RSf4ecf10e-d27c-4641-9888-6b497cfa0787] ON [dbo].[Equipment]
	(
		[Calibration2DismissAdvice] ASC,
		[QestOwnerLabNo] ASC,
		[NotInService] ASC,
		[NextCalibration2AdviseDate] ASC
	)
	INCLUDE ( 	[QestID],
		[QestUniqueID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- update the status of patch 41. This patch is responsibble for loading the custom reports and it seems to be failling during the upgrade.
-- The custom reports should be loaded manually through the QLA.
if (select count(*) from qestPatchStatus where PatchID = 41 and status = 2) > 0
begin
	update qestPatchStatus set status = 0, Description = 'This is done manually through the QLA. '+ convert(nvarchar(max),Description)
end