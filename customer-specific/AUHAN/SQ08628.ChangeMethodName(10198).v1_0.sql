-------------------------------------------------------------------------
-- SQ08628
-- Multiple sample agg/soil Test Report issue
-- 
-- Change Method name for 10198 from "Q134 Test Procedure" to "Q134 Test"
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 08 July 2016
-- Last Modified By: Salih Al Rashid
-- Last Modified: 08 July 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran
	update qestObjects 
	set value = 'Q134 Test'
	where qestID = 10198
	and Property = 'Method'
commit
