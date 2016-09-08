-------------------------------------------------------------------------
-- SQ07826
-- Hide CBR reporting 'Nominated % MDD' and 'Nominated % OMC'
-- 
-- This script will hide 'Nominated % MDD' and 'Nominated % OMC' from reporting
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 16 MAR 2016
-- Last Modified By: Salih AL Rashid
-- Last Modified: 16 MAR 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran
	update qestobjects
	set value = 'IsLong=T;FieldName=SpecifiedLabMCRatio;Prompt=Nominated % MDD;ValueFormat=R:T0:0.5r\;:0.5r;PrintFlagValue=''F''|'
	where qestid = 10592
	and property = 'ResultsFieldsLong9'

	update qestobjects
	set value = 'IsLong=T;FieldName=SpecifiedLabDDRatio;Prompt=Nominated % OMC;ValueFormat=R:T0:0.5r\;:0.5r;PrintFlagValue=''F''|'
	where qestid = 10592
	and property = 'ResultsFieldsLong10'
commit