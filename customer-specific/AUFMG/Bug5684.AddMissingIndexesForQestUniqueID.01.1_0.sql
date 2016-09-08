-------------------------------------------------------------------------
-- Bug5684 - Missing QestUniqueID Indexes
--
-- Adds an index on QestUniqueID for several tables missing this index
--  to improve query performance.
--
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 17 May 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 17 May 2016
-- 
-- Version: 1.0
-- Change Log
--		1.0		Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Once-off
-------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_Defaults_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[Defaults]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_Defaults_QestUniqueID] ON [dbo].[Defaults]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListBillableItem_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListBillableItem]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListBillableItem_QestUniqueID] ON [dbo].[ListBillableItem]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListClient_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListClient]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListClient_QestUniqueID] ON [dbo].[ListClient]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListComputer_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListComputer]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListComputer_QestUniqueID] ON [dbo].[ListComputer]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListContact_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListContact]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListContact_QestUniqueID] ON [dbo].[ListContact]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListFeeSchedule_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListFeeSchedule]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListFeeSchedule_QestUniqueID] ON [dbo].[ListFeeSchedule]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListHiveRoleMap_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListHiveRoleMap]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListHiveRoleMap_QestUniqueID] ON [dbo].[ListHiveRoleMap]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListLanguageTranslations_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListLanguageTranslations]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListLanguageTranslations_QestUniqueID] ON [dbo].[ListLanguageTranslations]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListProject_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListProject]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListProject_QestUniqueID] ON [dbo].[ListProject]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_ListTask_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[ListTask]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_ListTask_QestUniqueID] ON [dbo].[ListTask]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_qestNotifications_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[qestNotifications]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_qestNotifications_QestUniqueID] ON [dbo].[qestNotifications]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = N'IX_WorkTemplates_QestUniqueID' AND  object_id = OBJECT_ID(N'[dbo].[WorkTemplates]') )
CREATE UNIQUE NONCLUSTERED INDEX [IX_WorkTemplates_QestUniqueID] ON [dbo].[WorkTemplates]
(
	[QestUniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
