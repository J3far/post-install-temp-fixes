------------------------------------------------------------------------------------------------------------------------------------------------
-- Task 1166
-- HANSON Terel Upgrade

-- This script updates the status of patches that have failed during teh upgrade.

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 18/11/2015

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Needs to be run once if any of the patches faile. There is no harm in running multiple times though.
------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
set nocount on;

IF (SELECT Status FROM qestPatchStatus WHERE PatchID = 41) = 2
BEGIN
	UPDATE qestPatchStatus SET 
	Description = 'Upload the Test Report RPXs into the database, needs to be uploaded manually through the QLA -- FAILED. Error 457: This key is already associated with an element of this collection AddReportDetails: 0_18500',
	Status = 0
	WHERE PatchID = 41
END

COMMIT

