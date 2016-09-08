-------------------------------------------------------------------------
-- SQ08104
-- USTWI - QL CTR Report for CT 523 Remarks
-- 
-- This Script will edit the remarks for CT 523 Caltrans 
-- 
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 19 APRL 2016
-- Last Modified By: Salih AL Rashid
-- Last Modified: 19 APRL 2016
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update until bug #5612 is fixed
-------------------------------------------------------------------------


begin tran

	update qestObjects
	set Value = 'Specimen(s) prepared and cured to CT 523'
	where QestID in (68132,68106)
	and Property = 'NotePreparation1'
	and value = 'Specimen(s) prepared to CT 523'

commit