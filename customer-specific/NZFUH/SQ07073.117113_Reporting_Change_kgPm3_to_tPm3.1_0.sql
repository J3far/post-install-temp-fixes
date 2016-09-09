-------------------------------------------------------------------------
-- SQ07073
-- 4.1.1300 Bug - SASP Test Report

-- This script updates the unit of Theoretical Max. Density from kg/m³ to t/m³

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 25/11/2015

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: After any database update.
-------------------------------------------------------------------------
begin transaction
	update qestObjects set 
		value= 'FieldName=TheoMaxDensity;Prompt=Theoretical Max. Density (t/m³);ValueFormat=4sf;PrintIfNonNull=T|'
	where 
		QestID = 117113	and 
		Property='ResultsFieldsLong3' and
		value= 'FieldName=TheoMaxDensity;Prompt=Theoretical Max. Density (kg/m³);ValueFormat=4sf;PrintIfNonNull=T|'
commit