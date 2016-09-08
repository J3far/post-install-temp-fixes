-------------------------------------------------------------------------
-- SQ07255 Add Child Report for new CBR Tests
--
-- Allows California Bearing Ratio Test Report (18986)
-- to be added as a child of tests 10220 and 10215
--
-- Database: QESTLab
-- Created By: Christopher Kerr
-- Created Date: 9 February 2016
-- Last Modified By: Christopher Kerr
-- Last Modified: 9 February 2016
-- 
-- Version: 1.0
-- Change Log
--		1.0		Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After database structure updates until Bug 5122 is fixed
-------------------------------------------------------------------------


update
	QestObjects
set
	Value = Value + ',10220,10215'
where
	QestID = 18986
	and Property = 'Parents'
	and Value not like '%,10220,10215'