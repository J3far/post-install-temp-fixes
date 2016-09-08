-----------------------------------------------------------------------------
-- Field Density Report (17072)
-- Dry Density Ratio [AS 2891.14.5]
-- Incident: SQ05307
-- Related Items: CR2687
-- Author : Salih Al Rashid
-- Date Created : 05/06/2015

-- Change Log:
-- Version 1.0 - Original script

-- This scripts will:
-- Change the reporting of the 'Density Ratio' field on the Dry Density Report as per the standard. The standard states that the 
-- 'Density Ratio' must be reported to nearest 0.5% while it is reported to the nearest 0.1%.
-- There is an updated version of the AS 2891.14.5 standard, a change request has been logged to create the new screen.
-- workOrder:
-- - QestUniqueID = 3333

-- Expected Output: 
-- (1 row(s) affected)
-- (1 row(s) affected)
-----------------------------------------------------------------------------

BEGIN TRANSACTION
	UPDATE qestObjects
	SET value='FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.5r|'
	WHERE QestID=17072
	AND Property='COREWOResultsFieldsLong1'
	AND value = 'FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.0|'


	UPDATE qestObjects
	SET value='FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.5r|'
	WHERE QestID=17072
	AND Property='NDWOResultsFieldsLong1'
	AND value = 'FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.0|'

COMMIT TRANSACTION

-- Revert above changes to original

--begin transaction
--	update qestObjects
--	SET value = 'FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.0|'
--	where QestID=17072
--	and Property='COREWOResultsFieldsLong1'
--	and value='FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.5r|'

--	update qestObjects
--	SET value = 'FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.0|'
--	where QestID=17072
--	and Property='NDWOResultsFieldsLong1'
--	and value='FieldName=DensityRatio;Prompt=Density Ratio (%);ValueFormat=0.5r|'
	
--commit transaction