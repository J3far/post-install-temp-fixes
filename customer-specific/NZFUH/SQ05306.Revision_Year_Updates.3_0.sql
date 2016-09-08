----------------------------------------------------------------------
-- SQ05306
-- Revision Year Updates
--
-- Updates the revision year of the following standards
--	on the relevant test screens:  
--		   *ASTM D 36 (2014)
--		   *ASTM D 2196 (2015)
--		   *ASTM D 2726 (2014)
--		   *ASTM D 4402 (2013)
--		   *ASTM D 6927 (2015)
--		   *ASTM C 127 (2015)
--		   *ASTM C 128 (2015)
--		   *ASTM C 136 (2014)
--		   *AS/NZS 2891.2.2 (2014)
--          
--  Also adds missing method D 3203 to Height, Marshall Stability and Flow of Compacted Asphalt (Metric) (ID 117113)
--
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 04 May 2015
-- Last Modified By: Nathan Bennett
-- Last Modified: 06 Aug 2015
--
-- Version: 3.0
-- Change Log:
--   1.0 Initial Script
--   2.0 New requests (2/7/15)
--   3.0 New requests (6/8/15)
-- 
-- Repeatability: Safe
-- Re-run Requirement: After QEST.NET Upgrade
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
	raiserror('QESTID and property must not be null', 16, 1)
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
	DECLARE @UPDATE_OBSOLETE_SCREENS bit
	Set @UPDATE_OBSOLETE_SCREENS = 1 -- Set to 0 if obsoleted screens should not be updated

	--ASTM D 36 
	EXEC qest_IS_addUpdateProperty 117048, 'RevisionYear', '2014'

	--ASTM D 2196
	EXEC qest_IS_addUpdateProperty 117171, 'RevisionYear', '2015 Method A'
	EXEC qest_IS_addUpdateProperty 117171, 'Name', 'Brookfield Viscosity of Emulsion (Method A & Torque) [ASTM D 2196 - 15]'

	--ASTM D 2726
	EXEC qest_IS_addUpdateProperty 117136, 'RevisionYear', '2014a, 2011, 2011'
	EXEC qest_IS_addUpdateProperty 117126, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 117112, 'Method', 'ASTM D 2726 - 14, D 3549 - 11, D 3203 - 11'
	EXEC qest_IS_addUpdateProperty 117112, 'Name', 'Bulk Specific Gravity and Air Voids of Asphalt (Metric) [ASTM D 2726 - 14, D 3549 - 11, D 3203 - 11]'
	
	--ASTM D 4402  
	EXEC qest_IS_addUpdateProperty 117139, 'RevisionYear', '2015'
	
	--ASTM D 4867 
	EXEC qest_IS_addUpdateProperty 117161, 'RevisionYear', '2009'
	
	--ASTM D 6927 and ASTM D 3203
	EXEC qest_IS_addUpdateProperty 117113, 'Method', 'ASTM D 6927 - 15, D 6926 - 10, D 3549 - 11, D 2726 - 14a, D 3203 - 11'
	EXEC qest_IS_addUpdateProperty 117113, 'Name', 'Height, Marshall Stability and Flow of Compacted Asphalt (Metric) [ASTM D 6927 - 15, D 6926 - 10, D 3549 - 11, D 2726 - 14a, D 3203 - 11]'

	--ASTM C 127
	EXEC qest_IS_addUpdateProperty 110208, 'RevisionYear', '2015'
	IF @UPDATE_OBSOLETE_SCREENS = 1
	BEGIN
		--Superceded by ID 110208
		EXEC qest_IS_addUpdateProperty 110212, 'RevisionYear', '2015'
		EXEC qest_IS_addUpdateProperty 110212, 'Name', 'Specific Gravity and Absorption of Coarse Aggregate [ASTM C 127 - 15]'
	END
	
	--ASTM C 128
	EXEC qest_IS_addUpdateProperty 110207, 'RevisionYear', '2015'
	IF @UPDATE_OBSOLETE_SCREENS = 1
	BEGIN
		--Superceded by ID 110207
		EXEC qest_IS_addUpdateProperty 110222, 'RevisionYear', '2015'
		EXEC qest_IS_addUpdateProperty 110222, 'Name', 'Specific Gravity and Absorption of Fine Aggregate [ASTM C 128 - 15]'
	END
	
	--ASTM C 136
	EXEC qest_IS_addUpdateProperty 17153, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 117021, 'RevisionYear', '2014, 2004'
	EXEC qest_IS_addUpdateProperty 117021, 'Name', 'Sieve Analysis of Fine & Coarse Aggregate by Washing [ASTM C 136 - 14/C 117 - 04]'

	--AS/NZS 2891.2.2
	IF @UPDATE_OBSOLETE_SCREENS = 1
	BEGIN
		--Superceded by ID 17138
		EXEC qest_IS_addUpdateProperty 17130, 'RevisionYear', '2014'
		EXEC qest_IS_addUpdateProperty 17130, 'Caption', 'Compaction of Asphalt Specimens - {NumCycles} Cycles [AS/NZS 2891.2.2]'
		EXEC qest_IS_addUpdateProperty 17130, 'Name', 'Compaction of Asphalt Specimens [AS/NZS 2891.2.2]'
		EXEC qest_IS_addUpdateProperty 17130, 'Method', 'AS/NZS 2891.2.2'
	END

COMMIT transaction

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_addUpdateProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_addUpdateProperty]
GO