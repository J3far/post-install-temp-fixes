-------------------------------------------------------------------------
-- SQ08590
-- Q144A - no child report
-- 
-- Add child/parent relationship to theh following documents
-- 
--	Assigned Maximum Dry density - Q144A - 2010 (11251) - parent
--	Assignment of MDD and OMC (18999) - child
--
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 23 June 2016
-- Last Modified By: Salih Al Rashid
-- Last Modified: 29 June 2016
-- 
-- Version: 1.2
-- Change LOG
--	1.0 Original Version
--	1.1 Edited script to make report "Assignment of MDD and OMC" (18999) childe of test Assigned Maximum Dry Density [Q144A] (11251)
--	1.2 added another condition to the where clause
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran

	update qestObjects 
	set value = value + ',11251'
	where Property = 'Parents'
	and QestID = 18999
	and value not like '11251,%' 
	and value not like '%,11251,%' 
	and value not like '%,11251'
	and value not like '%11251%'

	update qestObjects 
	set value = Value + ',18999'
	where Property = 'AutoChildren'
	and QestID = 11251
	and value not like '18999,%' 
	and value not like '%,18999,%' 
	and value not like '%,18999'
	and value not like '%18999%'

commit