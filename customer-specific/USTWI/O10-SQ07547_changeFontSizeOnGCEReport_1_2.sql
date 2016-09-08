-------------------------------------------------------------------------
-- SQ07547
-- GCE Report Modification
-- 
-- Increase Sample fields and specimen headers font size
--
-- Database: QESTLab
-- Created By: Salih Al rashid
-- Created Date: 18 APRL 2016
-- Last Modified By: Salih Al rashid
-- Last Modified: 19 July 2016
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--  1.1 Fix margines to make sure all fields show properly
--	1.2 Fix the sample details column width issue in SQ08654
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran

	Update qestObjects 
	set Value = REPLACE(Value,'font-size: 7','font-size: 8')
	where QestID = 18947
	and value like '%ValueStyle=font-size: 7%'

	Update qestObjects 
	set Value = REPLACE(Value,'font-size: 6','font-size: 8')
	where QestID = 18947
	and value like '%ValueStyle=font-size: 6%'

	update qestObjects
	set value = 'SubReportTestResults=3500,2000,3500,1770|SubReportMixDataSource=0,0,0,0,1200,0,1200,0,800,0,800,0|SubReportSampleMeasurements=0,0,0,0,2025,0,1025,0,675,0,1175,0'
	where qestid = 18947
	and Property = 'BaseFieldColumnWidths'

commit
