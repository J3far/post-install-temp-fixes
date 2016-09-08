-------------------------------------------------------------------------
-- SQ07117
-- AU-IM006421598 - QEST Lab Asphalt - Wrong Standard Marshall Compaction AS2891.6 which should be AS2891.5.
-- 
-- Change CompactionMethod from 'Marshall=AS 2891.6' to 'Marshall=AS 2891.5' on objects '17162' & '17067' 
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 01 DEC 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 01 DEC 2015
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
	set value = 'Marshall=AS 2891.5'
	where qestID = 17067 
	and Property = 'CompactionMethod' 
	and value = 'Marshall=AS 2891.6'

	update qestObjects 
	set value = 'Marshall=AS 2891.5'
	where qestID = 17162
	and Property = 'CompactionMethod' 
	and value = 'Marshall=AS 2891.6'
commit
