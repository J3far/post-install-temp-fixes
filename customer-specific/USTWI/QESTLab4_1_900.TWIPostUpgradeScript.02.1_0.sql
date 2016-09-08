-------------------------------------------------------------------------
-- Twining Post-Upgrade Script
-- 
-- The following script will need to be executed after running the
--   QESTNET.Upgrade tool to reinstate a dropped index.
-- 
-- Database: QESTLab
--
-- Created By:  Nathan Bennett
-- Created Date: 23 Sep 2015
-- Last Modified By: Nathan Bennett
-- Last Modified: 23 Sep 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Once after upgrade
-------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_DocumentCertificates_StorageLookup' AND object_id = OBJECT_ID(N'[dbo].[DocumentCertificates]'))
	CREATE NONCLUSTERED INDEX [IX_DocumentCertificates_StorageLookup] ON [dbo].[DocumentCertificates]
	(
		[PortalUUID] ASC,
		[QestID] ASC,
		[QestUniqueID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_DocumentExternal_StorageLookup' AND object_id = OBJECT_ID(N'[dbo].[DocumentExternal]'))
	CREATE NONCLUSTERED INDEX [IX_DocumentExternal_StorageLookup] ON [dbo].[DocumentExternal]
	(
		[PortalUUID] ASC,
		[QestID] ASC,
		[QestUniqueID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO