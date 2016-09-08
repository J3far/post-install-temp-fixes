----------------------------------------------------------------------------------------------------------------------------
-- SQ07903
-- Remove Asphalt Test Report From Brookfield Viscosity Tests
--
-- This script will remove the Asphalt Test Report (With Records) [18987]
--  from being a child of the following tests:
--		Brookfield Viscosity of Asphalt (& Torque) [ASTM D 4402]  (ID 117139)
--		Brookfield Viscosity of Asphalt (& Torque) [ASTM D 4402 - 06]  (ID 117140)
--		Brookfield Viscosity of Emulsion (Method A & Torque) [ASTM D 2196] (ID 117141)
--		Brookfield Viscosity of Emulsion (Method A & Torque) [ASTM D 2196 - 10] (ID 117171).
--
-- Created By: Nathan Bennett
-- Created Date: 24 Mar 2016
-- Last Modified By: Nathan Bennett
-- Last Modified Date: 24 Mar 2016
--
-- Version 1.0
-- Change LOG
--  1.0 Original Version
--
-- Repeatability: Safe
-- Re-Run Requirement: After each QESTNET.Upgrade
----------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION

UPDATE QestObjects SET Value = '117113,117114,117107,117112,117136,117122,117123,17130,17133,17134,17155,17156,17138' WHERE Property = 'Parents' AND QestID = 18987

UPDATE QestObjects SET Value = '' WHERE Property = 'Autochildren' AND QestID IN (117139, 117140, 117141, 117171)

COMMIT TRANSACTION