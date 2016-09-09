-------------------------------------------------------------------------
-- SQ08785
-- NZS 4407 2015 Updates
-- 
-- Sets the reportng formats of Relative Compaction (%), Air Voids (%) and Deg. of Sat. (%) to the nearest 1 and 
-- Moisture (%) to the nearest 0.0 in theh following screens.
--
-- Relative Compaction (NZS)[10298]
-- Nuclear Field Density [NZS 4407:1991 Test 4.2.2][10332] 
-- Nuclear Field Density [NZS 4407:1991 Test 4.2.1][10331]
--
-- Created By: Iresha Jayasekara
-- Created Date: 08 August 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update 
-------------------------------------------------------------------------

BEGIN TRANSACTION

--Moisture (%)
UPDATE qestObjects SET [Value] = REPLACE(Value, '0.5r', '0.0')
WHERE QESTID IN (10331, 10332)
AND [Property] in (select Property from qestObjects where  Value like '%Moisture (%)%' and QESTID IN (10331, 10332) and Property like '%WOResultsFieldsLong%')

UPDATE qestObjects SET [Value] = REPLACE(Value, '0.5r', '0.0')
WHERE QESTID = 10298
AND [Property] in (select Property from qestObjects where  Value like '%Moisture (%)%' and QESTID = 10298 and Property like '%WOResultsFieldsLong%')


--Relative Compaction (%)
UPDATE qestObjects SET [Value] = REPLACE(Value, '0.0', '0')
WHERE QESTID = 10298
AND [Property] in (select Property from qestObjects where  Value like '%Relative Compaction (%)%' and QESTID = 10298 and Property like '%WOResultsFieldsLong%')

--Air Voids (%)
UPDATE qestObjects SET [Value] = REPLACE(Value, '0.0', '0')
WHERE QESTID = 10298
AND [Property] in (select Property from qestObjects where  Value like '%Air Voids (%)%' and QESTID = 10298 and Property like '%WOResultsFieldsLong%')

--Deg. of Sat. (%)
UPDATE qestObjects SET [Value] = REPLACE(Value, '0.0', '0')
WHERE QESTID = 10298
AND [Property] in (select Property from qestObjects where  Value like '%Deg. of Sat. (%)%' and QESTID = 10298 and Property like '%WOResultsFieldsLong%')


--ResultsFields

UPDATE qestObjects SET [Value] = REPLACE(Value, 'Moisture (%),>0.5r', 'Moisture (%),>0.0')
WHERE QESTID IN (10331, 10332)
AND [Property] = ('ResultsFields')

UPDATE qestObjects SET [Value] = REPLACE(Value, 'Moisture (%),0.5r', 'Moisture (%),0.0')
WHERE QESTID = 10298
AND [Property] = ('ResultsFields')

UPDATE qestObjects SET [Value] = REPLACE(Value, 'Relative Compaction (%),0.0|Saturation,Degree of Saturation (%),>0.0|AirVoids,Air Voids (%),0.0',
'Relative Compaction (%),0|Saturation,Degree of Saturation (%),>0|AirVoids,Air Voids (%),0')
WHERE QESTID = 10298
AND [Property] = ('ResultsFields') 

COMMIT TRANSACTION
 
