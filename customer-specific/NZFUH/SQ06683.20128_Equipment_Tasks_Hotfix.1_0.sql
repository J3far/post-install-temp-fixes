----------------------------------------------------------------------------------------------------------------------------
-- SQ06683
-- Equipment Calibration Task Types 'Error 91' Fix
--
-- This script hotfixes the Equipment Calibration Task Types which cause error 91 on equipmment, when selecting an equipment
-- calibration task type due to language checks
--
-- Created By: Shane Rowley
-- Created Date: 12-Nov-2015
-- Last Modified By: Shane Rowley
-- Last Modified Date: 12-Nov-2015
--
-- Version 1.0
-- Change LOG
--  1.0 Original Version
--
-- Repeatability: Safe
-- Re-Run Requirement: Once-Off. Except if new Equipment Tasks items are created, and the QestBaseLanguage is not defaulted. 
--   Script will be redundant once Bug 4971 is released 
----------------------------------------------------------------------------------------------------------------------------
begin tran

update ListTask
set QestBaseLanguage = 'EN-UK'

commit