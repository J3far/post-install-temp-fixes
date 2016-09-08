-------------------------------------------------------------------------
-- SQ08714
-- Cof16.142 Sodium Sulphate test error on Multi report
-- 
-- Fix issue resulted from SQ04954
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 04 August 2016
-- Last Modified By: Salih Al Rashid
-- Last Modified: 04 August 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran

	if not exists (select 1 from qestobjects where qestid in (10110,10111,10113,10112) and Property = 'ResultsFields' and value like 'QESTDateDiscard,Sodium Sulphate Soundness%') begin
		update qestobjects
		set value = 'QESTDateDiscard,Sodium Sulphate Soundness|' + value
		where qestID in (10110,10111,10113,10112)
		and Property = 'ResultsFields'
	end
	else
		Print '''QESTDateDiscard,Sodium Sulphate Soundness'' is already added to the ResultsFields for objects 10110,10111,10113 and 10112'
commit
