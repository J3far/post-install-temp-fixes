-------------------------------------------------------------------------
-- SQ08715
-- Cof16.143 - MC correlation test - extra report
-- 
-- Remove child report from object 11320
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 02 August 2016
-- Last Modified By: Salih Al Rashid
-- Last Modified: 02 August 2016
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
	set Value = replace(Value, ',11320','')
	where QestID = 18994
	and Property = 'Parents'
commit