-------------------------------------------------------------------------
-- SQ07795
-- Change Field Density Prompts on Relative Compaction (RMS) Report
-- 
-- The row labels "Field Wet Density in situ (t/m^3)" and "Field Dry Density in situ (t/m^3)" 
-- do not make it clear that the density is the result calculated for the lower layer. 
--
-- This script will change the field density labels reported for Relative Compaction RMS T166 (IDs 10282, 10566)
-- to "Field Wet Density Lower Layer (t/m^3)" and Field "Dry Density Lower Layer (t/m^3)" when
--    *a Nuclear Field Density test RMS T 173 (ID 10302) was performed
--    *the Nuclear Field Density test has a result for Wet Density at Position B.
--
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 08 MAR 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 09 MAR 2016
-- 
-- Version: 2.0
-- Change LOG
--	1.0 Original Version
--  2.0 Modified script to only change prompt to 'lower layer' if Wet Density recorded at Position B.
--      Also included the 2011 version of RMS T166 test
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin transaction

UPDATE qestobjects SET value = 'FieldName=labObject.[WetDensitySoil];PromptFieldName=Custom.IIF(Custom.IsNothing(Custom.SiblingDocument(labobject,''10302'')),''Field Wet Density in situ (t/m³)'',Custom.IIF(Custom.ReplaceNull(Custom.SiblingDocument(labobject,''10302'').[WetDensityB],-1)\=-1,''Field Wet Density in situ (t/m³)'', ''Field Wet Density Lower Layer (t/m³)''));ValueFormat=0.00;FieldType=2;|'
WHERE property = 'WOResultsFieldsLong5' AND QESTID In (10282, 10566)

UPDATE qestobjects SET value = 'FieldName=labObject.[BulkDryDensity];PromptFieldName=Custom.IIF(Custom.IsNothing(Custom.SiblingDocument(labobject,''10302'')),''Field Dry Density in situ (t/m³)'',Custom.IIF(Custom.ReplaceNull(Custom.SiblingDocument(labobject,''10302'').[WetDensityB],-1)\=-1,''Field Dry Density in situ (t/m³)'', ''Field Dry Density Lower Layer (t/m³)''));ValueFormat=0.00;FieldType=2;|'
WHERE property = 'WOResultsFieldsLong6' AND QESTID In (10282, 10566)

UPDATE qestobjects SET value = 'FieldName=labObject.[WetDensitySoil];PromptFieldName=Custom.IIF(Custom.IsNothing(Custom.SiblingDocument(labobject,''10302'')),''Field Wet Density in situ (t/m³)'',Custom.IIF(Custom.ReplaceNull(Custom.SiblingDocument(labobject,''10302'').[WetDensityB],-1)\=-1,''Field Wet Density in situ (t/m³)'', ''Field Wet Density Lower Layer (t/m³)''));ValueFormat=0.000;FieldType=2;|'
WHERE property = 'LotWOResultsFieldsLong5' AND QESTID In (10282, 10566)

UPDATE qestobjects SET value = 'FieldName=labObject.[BulkDryDensity];PromptFieldName=Custom.IIF(Custom.IsNothing(Custom.SiblingDocument(labobject,''10302'')),''Field Dry Density in situ (t/m³)'',Custom.IIF(Custom.ReplaceNull(Custom.SiblingDocument(labobject,''10302'').[WetDensityB],-1)\=-1,''Field Dry Density in situ (t/m³)'', ''Field Dry Density Lower Layer (t/m³)''));ValueFormat=0.000;FieldType=2;|'
WHERE property = 'LotWOResultsFieldsLong6' AND QESTID In (10282, 10566)

commit transaction


