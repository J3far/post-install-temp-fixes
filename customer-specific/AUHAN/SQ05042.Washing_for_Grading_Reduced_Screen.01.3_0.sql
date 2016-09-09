-----------------------------------------------------------------------------------------------------------------
-- SQ05042
-- Add Washed field to the reduced Grading screen (AS 1141.11.1).

-- This script allows the customer to record and report washing for
--  reduced test screen Grading [AS 1141.11.1] * (ID 10436).

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 05 Jan 2016
-- Last Modified By: Nathan Bennett
-- Last Modified Date: 04 Mar 2016

-- Version: 3.0
-- Change Log
--- 1.0 Original Version
--- 2.0 Used a new field for recording and reporting washing.
--- 3.0 Reverted to original field due to reporting issue.

-- Repeatability: Safe
-- Re-Run Requirement: Run after every DB update.
-----------------------------------------------------------------------------------------------------------------
begin transaction
-- If default exists on WashTotal, remove it.
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_DocumentParticleSizeDistribution_WashTotal]') AND type = 'D')
BEGIN    
   ALTER TABLE [dbo].[DocumentParticleSizeDistribution] DROP CONSTRAINT [DF_DocumentParticleSizeDistribution_WashTotal]    
END
GO

-- Fix fields for reduced test
UPDATE qestObjects SET value = 'CoefficientFm,Fineness Modulus,>0.0rb,-,CoefficientFmLimit|WashTotal, Washed,>0;\Y\e\s;\N\o,|DryingMethod,Drying Method,>LIST:Oven;Microwave;Hotplate;IR Lights;Heat Lamps;Blow Torch;Natural' WHERE QestID = 10436 AND Property = 'ResultsFields'
GO
commit transaction
 
