----------------------------------------------------------------------------------------
-- SQ06473
-- QestNet Upgrade error, invalid QESTID

-- This script removes the invalid records from the qestreverselook up records table.
-- The content of this script should be copied into the  QESTNET.Upgrade vx.yz\Scripts\data\data.corrections.after.qn.sql
-- before starting the QESTNET upgrade. If this si not done before the upgrade then the 
-- upgrade will stop at some point due to the invalid records in the qestreverselookup table.
-- In this case, if the error message is related to invalid QestIDs then it would be suficient
-- to run this script and continue the upgrade.


-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 15/10/2015

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: The content of this script should be copied into the  QESTNET.Upgrade vx.yz\Scripts\data\data.corrections.after.qn.sql
-- before starting the QESTNET upgrade.
----------------------------------------------------------------------------------------
-- Remove invalid qestReverseLookup entries
DELETE FROM qestReverseLookup WHERE QestID not in (SELECT QestID FROM qestObjects)
