-------------------------------------------------------------------------
-- SQ08080
-- New server destination for Test Certificate images QL->SAP
-- 
-- Change name and method property values in qestObjects for item (17025)
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 10 MAY 2016
-- Last Modified By: Salih Al Rashid
-- Last Modified: 10 MAY 2016
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
	set Value = 'AS 2891.3.1'
	where qestID = 17025
	and Property = 'Method'
	and value = 'AS 2891.3.1, AS 1141.11.1'

	update qestObjects
	set Value = 'Aggregate Grading [AS 2891.3.1]'
	where qestID = 17025
	and Property = 'Name'
	and value = 'Aggregate Grading [AS 2891.3.1, AS 1141.11.1]'

	-- old details
	--AS 2891.3.1, AS 1141.11.1
	--Aggregate Grading [AS 2891.3.1, AS 1141.11.1]
commit