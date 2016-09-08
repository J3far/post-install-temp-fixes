-------------------------------------------------------------------------
-- SQ07833
-- Create Procedure for User Document Initialisation
-- 
-- This script creates a procedure required to work around the issue
--   where new user document tables are not initialised correctly.
-- It also drops the trigger previously used to resolve SQ07833,
--   which is no longer required.
-- 
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 01 Apr 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 04 Apr 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Run once
-------------------------------------------------------------------------
BEGIN TRANSACTION

-- Remove database trigger as it is no longer required
IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'TR_AddTriggersToNewUserDocumentTables') 
	exec sp_executesql N'DROP TRIGGER [TR_AddTriggersToNewUserDocumentTables] ON DATABASE'
GO

-- Create procedure to set "Complete if Signed and Printed" for new user document test reports
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.qest_Workaround_CreateIndexesForNewTable'))
   exec sp_executesql N'DROP PROCEDURE [dbo].[qest_Workaround_CreateIndexesForNewTable]'
GO

CREATE PROCEDURE [dbo].[qest_Workaround_CreateIndexesForNewTable] 
	@TableName nvarchar(128)
AS
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max)

	-- Creates default indexes on a new table
	SET @SQL = N'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name=''IX_' + @TableName + '_QestUniqueID'' AND object_id = OBJECT_ID(''' + @TableName + ''')) 
	                     CREATE UNIQUE INDEX [IX_' + @TableName + '_QestUniqueID] ON [dbo].[' + @TableName + ']([QestUniqueID])'
	exec sp_executesql @SQL
						 
	SET @SQL = N'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name=''IX_' + @TableName + '_QestID'' AND object_id = OBJECT_ID(''' + @TableName + ''')) 
	                     CREATE INDEX [IX_' + @TableName + '_QestID] ON [dbo].[' + @TableName + ']([QestID])'
	exec sp_executesql @SQL
						 
	SET @SQL = N'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name=''IX_' + @TableName + '_QestParentID'' AND object_id = OBJECT_ID(''' + @TableName + ''')) 
	                     CREATE INDEX [IX_' + @TableName + '_QestParentID] ON [dbo].[' + @TableName + ']([QestParentID])'
	exec sp_executesql @SQL
						 
	SET @SQL =  N'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name=''IX_' + @TableName + '_QestUniqueParentID'' AND object_id = OBJECT_ID(''' + @TableName + ''')) 
	                     CREATE INDEX [IX_' + @TableName + '_QestUniqueParentID] ON [dbo].[' + @TableName + ']([QestUniqueParentID])'
	exec sp_executesql @SQL
GO

COMMIT TRANSACTION