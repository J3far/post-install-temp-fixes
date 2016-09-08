-------------------------------------------------------------------------
-- SQ07658 Performance Improvement - Create index on QestReportMapping.TestQestUUID
--
-- Improves performance when deleting objects in QESTLab
--
-- Database: QESTLab
-- Created By: Lief Martin
-- Created Date: 26 February 2016
-- Last Modified By: Gavin Schultz-Ohkubo
-- Last Modified: 8 April 2016
-- 
-- Version: 1.0
-- Change Log
--		1.0		Original Version
--    1.0a  Modified to remove WHERE clause, to allow SQL Server 2000 compatibility mode
--
-- Repeatability: Safe
-- Re-run Requirement: Once-off
-------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[qestReportMapping]') AND name = N'IX_qestReportMapping_CKTest')
DROP INDEX [IX_qestReportMapping_CKTest] ON [dbo].[qestReportMapping]
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[qestReportMapping]') AND name = N'IX_qestReportMapping_TestQestUUID')
DROP INDEX [IX_qestReportMapping_TestQestUUID] ON [dbo].[qestReportMapping]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[qestReportMapping]') AND name = N'IX_qestReportMapping_TestQestUUID')
CREATE NONCLUSTERED INDEX [IX_qestReportMapping_TestQestUUID] ON [dbo].[qestReportMapping]
(
	[TestQestUUID] ASC
)
INCLUDE ( 	[ReportQestID],
	[TestQestID],
	[ReportQestUniqueID],
	[TestQestUniqueID],
	[Mapping]) 
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
