-------------------------------------------------------------------------
-- SQ07726
-- Set SpecIsNumeric Field Where Null
-- 
-- Script that sets SpecIsNumeric field where null
-- This is required to fix specifications created by copying an existing
--  specification post 4.1 upgrade. 
-- Should be run once after installing the 4.1.1400 rebuild (which will fix this issue).
-- 
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 09 Mar 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 09 Mar 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Run once
-------------------------------------------------------------------------
BEGIN TRANSACTION
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES T INNER JOIN INFORMATION_SCHEMA.COLUMNS C ON T.TABLE_NAME = C.TABLE_NAME 
                WHERE T.TABLE_NAME = 'SpecificationRecords' AND C.COLUMN_NAME = 'SpecIsNumeric') 
BEGIN 
    UPDATE SpecificationRecords SET SpecIsNumeric = 
	CASE WHEN QestUniqueID IN (
		SELECT sr.QestUniqueID FROM SpecificationRecords sr 
		INNER JOIN (SELECT Property, Value, QestID FROM qestObjects WHERE Property = 'TableName') As qo ON qo.QestID = sr.ObjectID 
		INNER JOIN sys.columns c ON c.name = sr.Field 
		INNER JOIN sys.types t ON c.user_type_id = t.user_type_id 
		WHERE c.object_id = OBJECT_ID(qo.Value) and t.Name = 'bit') 
	THEN 0
	ELSE 1
	END
	WHERE SpecIsNumeric is NULL
END
COMMIT TRANSACTION
