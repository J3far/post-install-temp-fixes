----------------------------------------------------------------------------------------------------------------------------
-- Bug5594
-- Add Default Splice Types to List
--
-- The following script will add the following default Splice Types
--  to the list Steel Rebar Splice Type (ID 20089) at the global level
--  if they are not present.
--   *None
--   *Welded
--   *Mechanical Lap
--   *HRC
--   *Shear Bolt
--
-- Created By: Nathan Bennett
-- Created Date: 06-Jul-2016
-- Last Modified By: Nathan Bennett
-- Last Modified Date: 06-Jul-2016
--
-- Version 1.0
-- Change LOG
--  1.0 Original Version
--
-- Repeatability: Safe
-- Re-Run Requirement: Run once.
----------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION

IF OBJECT_ID('qest_AddSpliceType_TEMP', 'P') IS NOT NULL
	DROP PROCEDURE qest_AddSpliceType_TEMP
GO

CREATE PROCEDURE qest_AddSpliceType_TEMP 
   @SpliceType nvarchar(50)
AS 
	IF NOT EXISTS(SELECT * FROM ListSteelSpliceType WHERE QestOwnerLabNo = 0 AND SpliceTypeName = @SpliceType)
		INSERT INTO ListSteelSpliceType(qestID, QestCreatedDate,QestModifiedDate,QestOwnerLabNo,SpliceTypeName) VALUES (20089,getutcdate(),getutcdate(),0,@SpliceType)
GO

EXEC qest_AddSpliceType_TEMP 'None'
EXEC qest_AddSpliceType_TEMP 'Welded'
EXEC qest_AddSpliceType_TEMP 'Mechanical Lap'
EXEC qest_AddSpliceType_TEMP 'HRC'
EXEC qest_AddSpliceType_TEMP 'Shear Bolt'

DROP PROCEDURE qest_AddSpliceType_TEMP
GO

COMMIT TRANSACTION