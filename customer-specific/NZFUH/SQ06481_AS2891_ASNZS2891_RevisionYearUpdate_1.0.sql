----------------------------------------------------------------------
-- SQ06481_NZFUH_AS2891_ASNZS2891_RevisionYearUpdates_1.0.sql
-- NZ Test Method Update - NZS 4407 : 2015
-- 
-- The script will update the "RevisionYear" property for the methods marked with a (1) below
-- Tests that are not marked with a (1) do not have a "RevisionYear" Property

--17105,	2014,	Density Ratio of Asphalt Mixes for Airports[AAA MT 002 – 2007/AS 2891.9.1]							1
--17157,	2014,	Air Voids - 120 Cycles [AS 2891.8 DTEI]																1
--17158,	2014,	Air Voids - 350 Cycles [AS 2891.8 DTEI]																1
--17159,	2014,	Air Voids - 250 Cycles [AS 2891.8 DTEI]																1
--17160,	2014,	Air Voids - 80 Cycles [AS 2891.8 DTEI]																1
--17161,	2014,	Air Voids - 50 Cycles [AS 2891.8 DTEI]																1
--17162,	2014,	Air Voids (Marshall) [AS 2891.8 DTEI]																1
--17163,	2014,	Air Voids (Gyro) [AS 2891.8 DTEI]																	1
--110603,	2014,	Air Voids - 120 Cycles [AS/NZS 2891.8]																1
--110604,	2014,	Air Voids - 350 Cycles [AS/NZS 2891.8]																1
--110605,	2014,	Air Voids - 250 Cycles [AS/NZS 2891.8]																1
--110606,	2014,	Air Voids - 80 Cycles [AS/NZS 2891.8]																1
--110607,	2014,	Air Voids - 50 Cycles [AS/NZS 2891.8]																1
--110608,	2014,	Air Voids (Core) [AS/NZS 2891.8]																	1
--110609,	2014,	Air Voids (Marshall) [AS/NZS 2891.8]																1
--110610,	2014,	Air Voids (Gyro) [AS/NZS 2891.8]																	1
--110611,	2014,	Air Voids - 120 Cycles [AS/NZS 2891.8 DTEI]															1
--110612, 2014,	Air Voids - 350 Cycles [AS/NZS 2891.8 DTEI]																1
--110613,	2014,	Air Voids - 250 Cycles [AS/NZS 2891.8 DTEI]															1
--110614,	2014,	Air Voids - 80 Cycles [AS/NZS 2891.8 DTEI]															1
--110615,	2014,	Air Voids - 50 Cycles [AS/NZS 2891.8 DTEI]															1
--110616,	2014,	Air Voids (Marshall) [AS/NZS 2891.8 DTEI]															1
--110617, 2014,	Air Voids (Gyro) [AS/NZS 2891.8 DTEI]																	1
--17310,	2014,	Core Density (Multi-Site) [AS 2891.9.1]																1
--17314,	2014,	Core Density [AS 2891.9.1]																			1
--17142,	2014,	Bulk Density (Multi-Site) [AS/NZS 2891.9.2 - 14]													1
--17143,	2014,	Core Density [AS/NZS 2891.9.2 - 14]																	1
--17144,	2014,	Bulk Density [AS/NZS 2891.9.2 - 14]																	1
--17130,	2014,	Compaction of Asphalt Specimens [AS 2891.2.2]														1
--17138,	2014,	Compaction of Asphalt Specimens [AS/NZS 2891.2.2]													1
--17096,	2014,	Degree of Particle Coating [AS 2891.11]																1
--17131,	2013,	Resilient Modulus of Asphalt (No Pre-Condition) [AS 2891.13.1]										1
--17136,	2013,	Resilient Modulus of Asphalt - Direct Entry [AS 2891.13.1]											1
--17139,	2013,	Resilient Modulus of Asphalt (No Pre-Condition) [AS/NZS 2891.13.1 - 2013]							1
--17300,	2014,	Core Density [AS 2891.9.1] *																		
--17042,	2014,	Bulk Density (Multi-Site) [AS 2891.9.2]																
--17047,	2014,	Core Density [AS 2891.9.2]																			
--17080,	2014,	Bulk Density [AS 2891.9.2]																			
--17111,	2015,	Marshall Stability [AS 2891.5]																		
--17051,	2015,	Maximum Density [AS 2891.7.1]																		
--19199,	2014,	Asphalt Sample Preparation - Mixing, Quartering and Conditioning [AS 2891.2.1]						
--17046,	2014,	Bulk Density [AS 2891.9.1]																			
--17043,	2.14,	Bulk Density (Multi-Site) [AS 2891.9.3]																
--17048,	2014,	Core Density [AS 2891.9.3]																			
--17081,	2014,	Bulk Density [AS 2891.9.3]																			
--17081,	2014,	Bulk Density - {NoOfCycles} Cycles [AS 2891.9.3]													
--17060,	2014,	Air Voids - 120 Cycles [AS 2891.8]																		
--17061,	2014,	Air Voids - 350 Cycles [AS 2891.8]																	
--17062,	2014,	Air Voids - 250 Cycles [AS 2891.8]																	
--17063,	2014,	Air Voids - 80 Cycles [AS 2891.8]																	
--17064,	2014,	Air Voids - 50 Cycles [AS 2891.8]																	
--17066,	2014,	Air Voids (Core) [AS 2891.8]																		
--17067,	2014,	Air Voids (Marshall) [AS 2891.8]																	
--17068,	2014,	Air Voids (Gyro) [AS 2891.8]																		
--17072,	2014,	Dry Density Ratio [AS 2891.14.5]																	
--17052,	2014,	Maximum Density [AS 2891.7.3]																		
--17015,	2013,	Bitumen Content [AS 2891.3.1]																		
--17025,	2013,	Aggregate Grading [AS 2891.3.1, AS 1141.11.1]														
--19007,	2013,	Resilient Modulus [AS 2891.13.1]																	
--17010,	2013,	Bitumen Content [AS 2891.3.3]																		
--17020,	2013,	Aggregate Grading [AS 2891.3.3, AS 1141.11.1]														
--19245,	2013,	Asphalt Nuclear Density Testing - Vic Roads [AS/NZS 2891.14.2, RC316.00]							
--19249,	2013,	Asphalt Nuclear Density Offset [AS/NZS 2891.14.2]													
--17030,	2013,	Nuclear Field Density [AS 2891.14.2, RC 316.00]														
--17031,	2013,	Nuclear Field Density [AS 2891.14.2]																
--17032,	2013,	Density Offset [AS 2891.14.2]																		
--17035,	2013,	Density Offset [AS 2891.14.2.B, RC 316.00]															

-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 23 OCT 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 23 OCT 2015
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update

-- Notes: Procedure by Sean Brimble, Krzysztof Kot
----------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_addUpdateProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_addUpdateProperty]
GO

create procedure dbo.qest_IS_addUpdateProperty 
@qestid INT
, @property nvarchar(200)
, @DesiredValue nvarchar(1000)
AS

if @qestid is null or @property is null
begin
	raiserror('QESTID or/and property must not be null', 16, 1)
	return
end

if not exists (select [value] from qestObjects where qestid = @qestid and [property] = @property)
begin
	insert into qestObjects (QestID, QestActive, Property, Value) values (@qestid, 1, @property, @DesiredValue)
end
else
begin
	update qestObjects set [value] = @desiredValue where qestid = @qestid and [property] = @property
end
GO

BEGIN transaction
	--Update revision years
	EXEC qest_IS_addUpdateProperty 17105, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17105, 'Name', 'Density Ratio of Asphalt Mixes for Airports[AAA MT 002 – 2014/AS 2891.9.1]'
	EXEC qest_IS_addUpdateProperty 17157, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17158, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17159, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17160, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17161, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17162, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17163, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110603, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110604, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110605, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110606, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110607, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110608, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110609, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110610, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110611, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110612, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110613, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110614, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110615, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110616, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 110617, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17310, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17314, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17142, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17143, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17144, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17130, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17138, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17096, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17131, 'RevisionYear', '2013'
	EXEC qest_IS_addUpdateProperty 17136, 'RevisionYear', '2013'
	EXEC qest_IS_addUpdateProperty 17139, 'RevisionYear', '2013'

COMMIT transaction

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_addUpdateProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_addUpdateProperty]
GO