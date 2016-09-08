------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ08696
-- R value report on new test screen 110257

-- This script updates the parents on the R Value test report, 18964 to include the new R value test screen , 110257.

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 13/July/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Re-run after every DB update untill this gets fixed permenentaly.
------------------------------------------------------------------------------------------------------------------------------------------------
begin tran
	update qestObjects set Value = '110230,110231,110232,110233,110238,110257' where QestID = 18964 and Property = 'Parents'
commit
