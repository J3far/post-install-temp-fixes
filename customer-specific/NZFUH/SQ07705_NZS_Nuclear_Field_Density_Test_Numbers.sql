------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ07705
-- NZS Nuclear Field Density Test Number changes

-- This script updates the NZS nuclar density tests numbers:
-- 4.2.1 to 4.2 and
-- 4.2.2 to 4.3

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 22/02/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Once-off
------------------------------------------------------------------------------------------------------------------------------------------------
update qestobjects set value = 'NZS 4407:2015 Test 4.2' where qestid = 10331 and property = 'Method'
update qestobjects set value = 'Nuclear Field Density [NZS 4407:2015 Test 4.2]' where qestid = 10331 and property = 'Name'

update qestobjects set value = 'NZS 4407:2015 Test 4.3' where qestid = 10332 and property = 'Method'
update qestobjects set value = 'Nuclear Field Density [NZS 4407:2015 Test 4.3]' where qestid = 10332 and property = 'Name'
