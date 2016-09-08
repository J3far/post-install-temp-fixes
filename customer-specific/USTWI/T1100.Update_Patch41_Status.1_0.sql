-------------------------------------------------------------------------
-- Twining Post-Upgrade Script
-- 
-- This script will update the patch status of patch 41 if it fails.
-- 
-- Database: QESTLab
--
-- Created By:  Jafar AL Rashid
-- Created Date: 24 Sep 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After every database upgrade if patch 41 fails.
-------------------------------------------------------------------------
if not exists(select * from qestPatchStatus where PatchID = 41) 
begin
	insert into qestPatchStatus (PatchID,Status,Description) values(41,0, 'Upload the Test Report RPXs into the database, Uploaded manualy. -- FAILED. Error 457: This key is already associated with an element of this collection AddReportDetails: 0_18500');
end
	update qestPatchStatus set Status = 0,Description = 'Upload the Test Report RPXs into the database, Uploaded manualy. -- FAILED. Error 457: This key is already associated with an element of this collection AddReportDetails: 0_18500' where  PatchID = 41 and Status =2
