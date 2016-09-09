----------------------------------------------------------------------
-- SQ05677_NZFUH_RevisionYearUpdates.sql
--
-- Author: Nathan Bennett
-- Date Modified: 2nd July 2015
-- Description:
--   Updates the revision year of requested QMR methods to 2014
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
	--Update revision years
	EXEC qest_IS_addUpdateProperty 10226, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10227, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10228, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10229, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10230, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10272, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10522, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10523, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10654, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 10655, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17078, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17082, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17083, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17086, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17087, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17088, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17089, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17100, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17112, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17156, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17166, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17304, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17305, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17306, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17307, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17308, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17309, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17311, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17312, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 17313, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19324, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19325, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19326, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19327, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19328, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19331, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 19337, 'RevisionYear', '2014'
	EXEC qest_IS_addUpdateProperty 117038, 'RevisionYear', '2014'

COMMIT transaction

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_addUpdateProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_addUpdateProperty]
GO