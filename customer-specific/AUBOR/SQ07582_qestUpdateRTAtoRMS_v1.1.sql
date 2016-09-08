-------------------------------------------------------------------------
-- SQ07582
-- Scrupt to convert RTA to RMS
-- 
-- This script will Convert all occurance of RTA to RMS for all methods available in QESTLab
-- 
-- Database: QESTLab
-- Created By: Script written by Benny Thomas put together by Salih AL Rashid
-- Created Date: 02 JAN 2016
-- Last Modified By: Salih AL Rashid
-- Last Modified: 02 JAN 2016
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--	1.1 add header
--
-- Repeatability: Unsafe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin transaction

UPDATE qestObjects SET Value = REPLACE(Value,'RTA ', 'RMS ') WHERE Value LIKE '%RTA %'
UPDATE qestObjects SET Value = REPLACE(Value,'(RTA)', '(RMS)') WHERE Value LIKE '%(RTA)%'
UPDATE qestObjects SET Value = REPLACE(Value,'[RTA]', '[RMS]') WHERE Value LIKE '%[RTA]%'
UPDATE qestObjects SET Value = REPLACE(Value,'RTA', 'RMS') WHERE Property IN ('Method', 'ReportingBody')

commit