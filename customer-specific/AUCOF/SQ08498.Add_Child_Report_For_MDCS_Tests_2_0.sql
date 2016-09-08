----------------------------------------------------------------------------------------------------------------------------
-- SQ08498
-- Update the parents property of Maximum Dry Density Report(18995) so Maximum Dry Compressive Strength tests can have the report as child.
--
-- 
-- Created By: Weiwen Chi
-- Created Date: 06-June-2016
-- Modified Date: 07-June-2016
--
-- Version 2.0
-- Change Log
--  1.0 Original Version
--  2.0 Updating the re-run requirement
--
-- Repeatability: Safe
-- Re-Run Requirement: After database upgrade
----------------------------------------------------------------------------------------------------------------------------
BEGIN TRAN
DELETE FROM qestObjects WHERE QestID=18995 AND Property='ParentsByTable'

DECLARE @value NVARCHAR(MAX)
DECLARE @sql NVARCHAR(MAX)

SELECT @value='10564,10565'

SELECT @value=(@value+ ',' + CAST(Qestid AS NVARCHAR))
FROM qestObjects
WHERE Property='TableName' AND Value='DocumentMaximumDryDensity'

SELECT @sql =
'UPDATE  qestObjects
SET Value='''+ @value + '''
WHERE QestID=18995 AND Property=''Parents'''

EXEC sp_executesql @sql

COMMIT


