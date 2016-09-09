-------------------------------------------------------------------------
-- SQ07825
-- Fix Read Only PSV Certificates
-- 
-- This script will correct PSV Certificates which were set as "complete"
--  due to a default on the QestComplete field, and hence initialised
--  as "read only". 
--
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 21 Mar 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 21 Mar 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Run once
-------------------------------------------------------------------------

BEGIN TRANSACTION
--The doc-level options "Complete if signed and printed" and "Complete if signed and emailed" are not present on ID 19167,
--  so QestComplete is determined by whether report is signed only.
UPDATE DocumentExternal SET QestComplete = CASE WHEN COALESCE(SignatoryID, 0) > 0 THEN 1 ELSE 0 END WHERE QestID = 19167
COMMIT TRANSACTION