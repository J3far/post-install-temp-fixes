-------------------------------------------------------------------------
-- SQ06016
-- [RMS] Compressive Cores (0.1 MPa Precision)
-- 
-- [RMS] Compressive Cores (0.1 MPa Precision) is not displayed under Roles > Specimens
-- This is because the property "ActivityDependency=1602", it should be "ActivityDependency=1604" 
-- (referencing the AU concrete sample, not the US concrete sample)
-- The script will change the property to the correct value
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 05 August 2015
-- Last Modified By: Krzysztof Kot
-- Last Modified: 28 August 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--  1.1 Corrected re-run requirements
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

BEGIN TRANSACTION 
	UPDATE qestObjects
	SET Value = 1604
	WHERE QestID = 68404
	AND Property = 'ActivityDependency'
	AND Value = 1602
 COMMIT TRANSACTION