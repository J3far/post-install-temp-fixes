---------------------------------------------------------------------------------------------------------------------------------
-- Incident SQ08830
-- Add 'Source' to 'Testing Details' for the Field Density Report [18988] for all views.

-- This script will add the material 'Source' to the 'Testing Details' section of the report for the four views (Road, Fill, Plateau and Site) of the 'Field Density Report'. 
-- Database: QESTLab
-- Created By : Benjamin Riches
-- Created Date : 24/08/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: After any database upgrade.
---------------------------------------------------------------------------------------------------------------------------------

--Necessary functions for stript to begin:

if OBJECT_ID('qestobjects_property_exists','FN') is not null
	drop function dbo.qestobjects_property_exists
go
create function dbo.qestobjects_property_exists (@qestid int,@property_like nvarchar(500),@value_like nvarchar(max))
returns bit
as
begin
	declare @return bit = 0;
	set @return = (select CAST(1 AS BIT) from qestObjects where QestID = @qestid and Property like @property_like and Value like @value_like);
	return @return;
end
go

-- get last property like
if OBJECT_ID('qestobjects_last_property','FN') is not null
	drop function dbo.qestobjects_last_property
go
create function dbo.qestobjects_last_property (@qestid int,@property nvarchar(500))
returns nvarchar(500)
as
begin
	declare @return nvarchar(500);

	set @return = (select @property+convert(nvarchar(5),count(*)) from qestObjects where QestID = @qestid and Property like @property+'%' group by QestID );

	return @return;
end
go

-- next property, use for fields like Results1,Results2,.....
if OBJECT_ID('qestobjects_next_property','FN') is not null
	drop function dbo.qestobjects_next_property
go
create function dbo.qestobjects_next_property (@qestid int,@property nvarchar(500))
returns nvarchar(500)
as
begin
	declare @return nvarchar(500);

	set @return = (select @property+convert(nvarchar(5),count(*)+1) from qestObjects where QestID = @qestid and Property like @property+'%' group by QestID );

	return @return;
end
go

-- get a property based on value and qestid
if OBJECT_ID('qestobjects_get_property','FN') is not null
	drop function dbo.qestobjects_get_property
go
create function dbo.qestobjects_get_property (@qestid int,@value_like nvarchar(500))
returns nvarchar(500)
as
begin
	declare @return nvarchar(500);

	set @return = (select top 1 case when count(*) = 1 then Property else null end from qestObjects where QestID = @qestid and Value like @value_like group by QestID,Property );

	return @return;
end
go




-- Code for the fields being inserted:

-- Road Sample Details (default):
if (select dbo.qestobjects_property_exists(18988,'%SampleDetailsLong%','%SourceName%')) is null
begin 
		update qestObjects set Value = value + '|' where QestID = 18988 and Value like '%FieldName%' and Value not like '%|' and property like '%SampleDetailsLong%'
		insert into qestObjects (QestID,QestActive,QestExtra,Property,value) values (18988,1,0,(select dbo.qestobjects_next_property(18988,'SampleDetailsLong')),'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;');	
end
	update qestobjects set value = 'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;' where QestID = 18988 and Property = dbo.qestobjects_get_property(QestID,'%SourceName%') and Property=dbo.qestobjects_get_property(QestID,'%SampleDetailsLong%')

-- Site Sample Details:
if (select dbo.qestobjects_property_exists(18988,'%SiteSampleDetailsLong%','%SourceName%')) is null
begin 
		update qestObjects set Value = value + '|' where QestID = 18988 and Value like '%FieldName%' and Value not like '%|' and property like '%SiteSampleDetailsLong%'
		insert into qestObjects (QestID,QestActive,QestExtra,Property,value) values (18988,1,0,(select dbo.qestobjects_next_property(18988,'SiteSampleDetailsLong')),'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;');	
end
	update qestobjects set value = 'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;' where QestID = 18988 and Property = dbo.qestobjects_get_property(QestID,'%SourceName%') and Property=dbo.qestobjects_get_property(QestID,'%SiteSampleDetailsLong%')

--Fill Sample Details
if (select dbo.qestobjects_property_exists(18988,'%FillSampleDetailsLong%','%SourceName%')) is null 
begin
		update qestObjects set Value = value + '|' where QestID = 18988 and Value like '%FieldName%' and Value not like '%|' and property like '%FillSampleDetailsLong%'
		insert into qestObjects (QestID,QestActive,QestExtra,Property,value) values (18988,1,0,(select dbo.qestobjects_next_property(18988,'FillSampleDetailsLong')),'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;');
end	
	update qestobjects set value = 'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;' where QestID = 18988 and Property = dbo.qestobjects_get_property(QestID,'%SourceName%') and Property=dbo.qestobjects_get_property(QestID,'%FillSampleDetailsLong%')

--Plateau Sample Details
if (select dbo.qestobjects_property_exists(18988,'%PlateauSampleDetailsLong%','%SourceName%')) is null 
begin
		update qestObjects set Value = value + '|' where QestID = 18988 and Value like '%FieldName%' and Value not like '%|' and property like '%PlateauSampleDetailsLong%'
		insert into qestObjects (QestID,QestActive,QestExtra,Property,value) values (18988,1,0,(select dbo.qestobjects_next_property(18988,'PlateauSampleDetailsLong')),'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;');
end
	update qestobjects set value = 'FieldName=SourceName;Prompt=Source;IsLong=T;IsCommon=T;' where QestID = 18988 and Property = dbo.qestobjects_get_property(QestID,'%SourceName%') and Property=dbo.qestobjects_get_property(QestID,'%PlateauSampleDetailsLong%')