----------------------------------------------------------------------
-- Remove Autochildren from Brookfield Viscosity of Asphalt (& Torque) [ASTM D 4402] - 2012
--
-- Author: Sean Brimble
-- Date Modified: 27th July 2015
-- Description:
-- SQ05940 - Remove Auto-Child test report from Brookfield Viscosity of Asphalt 
-- (& Torque) [ASTM D 4402] - 2012
----------------------------------------------------------------------


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_DeleteProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_DeleteProperty]
GO

create procedure dbo.qest_IS_DeleteProperty 
@qestid INT
, @property nvarchar(200)
AS

if @qestid is null or @property is null
begin
	raiserror('QESTID and property must not be null', 16, 1)
	return
end

if not exists (select [value] from qestObjects where qestid = @qestid and [property] = @property)
begin
	raiserror('The selected property does not exists for the specified QESTID.', 16, 1)
end
else
begin
	delete from qestObjects where qestid = @qestid and [property] = @property
end
GO

begin transaction
	declare @p nvarchar (200)
	
	select @p = 'AutoChildren'

	--Brookfield Viscosity of Asphalt (& Torque) [ASTM D 4402] - 2012
	EXEC qest_IS_DeleteProperty @qestid = 117139, @property = @p
	--Brookfield Viscosity of Asphalt (& Torque) [ASTM D 4402] - 2006
	--EXEC qest_IS_DeleteProperty @qestid = 117140, @property = @p
commit transaction

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qest_IS_DeleteProperty]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qest_IS_DeleteProperty]
GO

