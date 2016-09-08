-------------------------------------------------------------------------
-- Prevent QESTLab Admin Console Deleting Columns 
-- Ref: Bug 5572
--
-- Changes stored proc qest_GetCustomFields_Extraneous
-- to always return no rows, prevent QESTLab Admin Console
-- from removing columns when modifying Custom Fields.
--
-- Recreates the original procedure as qest_GetCustomFields_Unknown
-- to assist in locating obsolete Custom Fields and scripted-in fields
--
-- Database: QESTLab
-- Created By: Christopher Kerr
-- Created Date: 8 April 2016
-- Last Modified By: Christopher Kerr
-- Last Modified: 8 April 2016
-- 
-- Version: 1.0
-- Change Log
--		1.0		Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After database updates until bug #5572 is fixed
-------------------------------------------------------------------------


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_GetCustomFields_Extraneous]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_GetCustomFields_Extraneous]

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_GetCustomFields_Unknown]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_GetCustomFields_Unknown]

GO


CREATE PROCEDURE [dbo].[qest_GetCustomFields_Unknown]
AS
BEGIN
	-- CK 20160408 - Original version of qest_GetCustomFields_Extraneous, renamed to qest_GetCustomFields_Unknown
    SELECT cmain.COLUMN_NAME, cmain.TABLE_NAME, cmain.DATA_TYPE, cmain.CHARACTER_MAXIMUM_LENGTH, *
    FROM INFORMATION_SCHEMA.COLUMNS cmain
		INNER JOIN INFORMATION_SCHEMA.TABLES t ON (t.TABLE_NAME = cmain.TABLE_NAME AND t.TABLE_TYPE = 'BASE TABLE')
    WHERE cmain.COLUMN_NAME LIKE '[_]%' AND cmain.TABLE_SCHEMA = 'dbo'
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.CustomFieldSets sets
            INNER JOIN dbo.CustomFieldSetDocTypes docs ON docs.CustomSetID = sets.CustomSetID
            INNER JOIN dbo.CustomFieldSetFields flds ON flds.CustomSetID = sets.CustomSetID
            INNER JOIN dbo.qestObjects qo ON docs.QestID = qo.QestID AND qo.Property = 'TableName'
            INNER JOIN INFORMATION_SCHEMA.COLUMNS cols ON cols.TABLE_NAME = qo.Value AND cols.COLUMN_NAME = flds.FieldName
        WHERE flds.FieldName = cmain.COLUMN_NAME AND cols.TABLE_NAME = cmain.TABLE_NAME
    )
END

GO

CREATE PROCEDURE [dbo].[qest_GetCustomFields_Extraneous]
AS
BEGIN
	-- CK 20160408 - Disable qest_GetCustomFields_Extraneous by selecting 0 results
	-- See qest_GetCustomFields_Unknown for the original functionality
    SELECT TOP 0 cmain.COLUMN_NAME, cmain.TABLE_NAME, cmain.DATA_TYPE, cmain.CHARACTER_MAXIMUM_LENGTH, *
    FROM INFORMATION_SCHEMA.COLUMNS cmain
		INNER JOIN INFORMATION_SCHEMA.TABLES t ON (t.TABLE_NAME = cmain.TABLE_NAME AND t.TABLE_TYPE = 'BASE TABLE')
    WHERE cmain.COLUMN_NAME LIKE '[_]%' AND cmain.TABLE_SCHEMA = 'dbo'
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.CustomFieldSets sets
            INNER JOIN dbo.CustomFieldSetDocTypes docs ON docs.CustomSetID = sets.CustomSetID
            INNER JOIN dbo.CustomFieldSetFields flds ON flds.CustomSetID = sets.CustomSetID
            INNER JOIN dbo.qestObjects qo ON docs.QestID = qo.QestID AND qo.Property = 'TableName'
            INNER JOIN INFORMATION_SCHEMA.COLUMNS cols ON cols.TABLE_NAME = qo.Value AND cols.COLUMN_NAME = flds.FieldName
        WHERE flds.FieldName = cmain.COLUMN_NAME AND cols.TABLE_NAME = cmain.TABLE_NAME
    )
END

GO


