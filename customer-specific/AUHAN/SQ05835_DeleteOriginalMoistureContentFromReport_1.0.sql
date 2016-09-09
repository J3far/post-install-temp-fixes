-------------------------------------------------------------------------
-- SQ05835
-- Hanson#91 Licence File for Q102D Subsidiary Moisture Content of Soil - hotplate drying
-- 
-- This script will delete the "Original Moisture Content (%)" from the report
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 07 OCT 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 07 OCT 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------
BEGIN TRANSACTION
	UPDATE qestObjects
	SET Value = 'MoistureContent,Moisture Content (%),0.0rb'
	where QestID = 11003
	and Property = 'ResultsFields'
	and Value = 'MoistureContent,Moisture Content (%),0.0rb|AmendedMoisture,Original Moisture Content (%),>0.0rb'
COMMIT TRANSACTION
