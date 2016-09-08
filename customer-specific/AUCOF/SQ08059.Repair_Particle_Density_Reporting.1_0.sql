----------------------------------------------------------------------------------------------------------------------------*
-- SQ08059
-- Repairs the Particle Density result fields for AS 1141.6.1 (10096) and AS 1141.6.2 (10320) to report results when some are not set.
--
-- The test screen is used by other tests which have multiple specimens. Averages of these specimens are calculated, but all results
-- have to valid. Instead, the script changes the tests to report the first specimens result, since there is only one specimen for 
-- these tests, and therefore the average technically equals the first specimens results
--
-- Created By: Shane Rowley
-- Created Date: 19-Mar-2016
-- Modified Date: 19-Mar-2016
--
-- Version 1.0
-- Change Log
--  1.0 Original Version
--
-- Repeatability: Safe
-- Re-Run Requirement: With every QEST Admin Console, database update. 
--  Will be fixed with Bug 5596
----------------------------------------------------------------------------------------------------------------------------
begin tran

update qestObjects
set Value = 'ApparentParticleDensity1,Apparent Particle Density - Coarse (t/m³),0.00|ParticleDensityDry1,Particle Density Dry (t/m³),0.00|ParticleDensitySSD1,Particle Density SSD (t/m³),0.00|WaterAbsorption1,Water Absorption (%),0.0'
where QestID = 10096 and Property = 'ResultsFields'

update qestObjects
set Value = 'ApparentParticleDensity1,Apparent Particle Density (t/m³),0.00|ParticleDensityDry1,Particle Density Dry (t/m³),0.00|ParticleDensitySSD1,Particle Density SSD (t/m³),0.00|WaterAbsorption1,Water Absorption (%),0.0'
where QestID = 10320 and Property = 'ResultsFields'

commit