------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ08488
-- Asphalt Density Report Configurations.

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 06/06/2016
-- Modified Date: 28/06/2016

-- Version: 4.0
-- Change Log
--- 1.0 Original Version
--- 4.0 Decreased width of the Comp(%) field and increased the width of the Limit(%) field so it can fit inclusive specs.

-- Repeatability: Safe
-- Re-Run Requirement: After any database upgrade.
------------------------------------------------------------------------------------------------------------------------------------------------

set nocount on;
-- Stored procedure for adding Qest Object Properties
IF OBJECT_ID('[dbo].[temp_AddObjectProperty]') is not null
BEGIN
    DROP PROCEDURE [dbo].[temp_AddObjectProperty]
END
GO

CREATE PROC [dbo].[temp_AddObjectProperty]
	@QestID int, 
	@QestActive bit, 
	@QestExtra bit, 
	@Property nvarchar(32) = '',
	@Value nvarchar(4000),
	@newProperty bit = 0, -- if the property is new then it will be inserted at the required position, else if the property exists it will be updated
	@printQueries bit = 1,
	@executeQueries bit = 0,
	@allowDuplicates bit = 0 -- 0 will prevent the records with same qestid, property and value to be added

AS
	if @Property is null or LTRIM(RTRIM(@Property)) = ''
	begin
		raiserror('No @Property and no @baseProperty were supplied.',11,1);
		return;
	end

	-- check the value
	if @Value is null or LTRIM(RTRIM(@Value)) = ''
	begin
		raiserror('Invalid value.',11,1);
		return;
	end


	declare @position int = (SELECT convert(int,SUBSTRING(@Property, PATINDEX('%[0-9]%', @Property), LEN(@Property))));
	declare @baseProperty nvarchar(32) = replace(@Property,convert(nvarchar(10),@position),'');
	declare @qestObjects table (QestID int,QestActive bit,QestExtra bit,Property nvarchar(300),value nvarchar(1000));
	declare @counter int = 0;

	insert into @qestObjects (QestID,QestActive,QestExtra,Property,value) values (@QestID,@QestActive,@QestExtra,@Property,@Value);


	-- option 1, use the @Property & the flag @newProperty to insert a new value or update existing one
	if @Property is not null and LTRIM(RTRIM(@Property)) <> ''
		begin

		-- if this is a new property
		if @newProperty = 1
			begin

				-- check to see if the Property & the value already exist int the DB
				if exists (select * from qestObjects where QestID = @QestID and Property = @Property and Value = @Value) and @allowDuplicates = 0
				begin
					print 'The property '+@Property+' and the value '+@Value+' already exist on this object. If you want to add it anyway, use the flag @allowDuplicates = 1';
					return;
				end
				-- get all the successive properties and put in a temp table
				while exists (select * from qestObjects where QestID = @QestID and Property = @Property)
				begin
					set @counter = @counter+1;
					insert into @qestObjects (QestID,QestActive,QestExtra,Property,value) select QestID,QestActive,QestExtra,@baseProperty+convert(nvarchar(10),@position+@counter),Value from qestObjects where QestID = @QestID and Property = @Property;
					set @Property = @baseProperty+convert(nvarchar(10),@position+@counter);
				end


				if @executeQueries = 1 
				begin
					-- update existing properties
					update c
					set c.Value = n.value
					from @qestObjects n
					inner join qestObjects c on c.QestID = n.QestID and c.Property = n.Property;

					-- insert the properties that dont exist
					INSERT INTO dbo.qestObjects(QestID,QestActive,QestExtra,[Property],[Value])
					select n.QestID,n.QestActive,n.QestExtra,n.[Property],n.[Value]
					from @qestObjects n
					left join qestObjects c on c.QestID = n.QestID and c.Property = n.Property
					where c.QestUniqueID is null

				end

				if @printQueries = 1
				begin
					select 'update qestObjects set value = '''+replace(n.[Value],'''','''''')+''' where QestID = '+convert(nvarchar(10),n.QestID)+' and Property = '''+n.Property+''';'  from @qestObjects n
					inner join qestObjects c on c.QestID = n.QestID and c.Property = n.Property


					-- insert the properties that dont exist
					select 'if not exists(select * from qestObjects where qestID = '+convert(nvarchar(10),n.QestID)+' and Property = '''+n.[Property]+''') INSERT INTO dbo.qestObjects(QestID,QestActive,QestExtra,[Property],[Value]) values ('+convert(nvarchar(10),n.QestID)+','+convert(nvarchar(1),n.QestActive)+','+convert(nvarchar(1),n.QestExtra)+','''+n.[Property]+''','''+replace(n.[Value],'''','''''')+''');'
					from @qestObjects n
					left join qestObjects c on c.QestID = n.QestID and c.Property = n.Property
					where c.QestUniqueID is null
				end
				return;
			end

		else -- if it is not a new property
			begin
				-- raise an error if the property does not exist because the flag @newProperty = 0
				if (select count(*) from QestObjects where QestID = @QestID and Property = @Property) = 0
				begin
					raiserror('The Property %s does not exists. If you would like to add this property then use the flag @newProperty = 1 instead.',11,1,@Property);
					return;
				end

				if @printQueries = 1
				-- if the property exists then update it
				select 'update dbo.qestObjects set Value = '''+replace(@Value,'''','''''')+''', QestActive = '+convert(nvarchar(1),@QestActive)+', QestExtra = '+convert(nvarchar(1),@QestExtra)+' where QestID = '+convert(nvarchar(10),@QestID)+' and Property = '''+@Property+''';';

				if @executeQueries = 1 
				update dbo.qestObjects set Value = @Value, QestActive = @QestActive, QestExtra = @QestExtra where QestID = @QestID and Property = @Property;

				return;
	
			end		
		end
GO

IF OBJECT_ID('[dbo].[temp_RemoveObjectProperty]') is not null
BEGIN
    DROP PROCEDURE [dbo].[temp_RemoveObjectProperty]
END
GO

CREATE PROC [dbo].[temp_RemoveObjectProperty]
	@QestID int, 
	@Property nvarchar(32),
	@Value nvarchar(4000),
	@printQueries bit = 1,
	@executeQueries bit = 0

AS
	if @Property is null or LTRIM(RTRIM(@Property)) = ''
	begin
		raiserror('Invalid Property.',11,1);
		return;
	end

	if not exists (select * from qestObjects where QestID = @QestID and Property = @Property and Value = @Value)
	begin
		raiserror('Invalid QestID,Proprty, Value combinations or this property has already been deleted. The Property = %s and the value = %s ',1,1,@property,@value);
		return;
	end

	declare @position int = (SELECT convert(int,SUBSTRING(@Property, PATINDEX('%[0-9]%', @Property), LEN(@Property))));
	declare @baseProperty nvarchar(32) = replace(@Property,convert(nvarchar(10),@position),'');
	declare @qestObjects table (QestID int,QestActive bit,QestExtra bit,Property nvarchar(300),value nvarchar(1000));
	declare @counter int = 1;
	
	--insert into @qestObjects (QestID,QestActive,QestExtra,Property,value) values (@QestID,@Property);


	-- option 1, use the @Property & the flag @newProperty to insert a new value or update existing one
	if @Property is not null and LTRIM(RTRIM(@Property)) <> ''
		begin
			-- get all the successive properties and put in a temp table
			while exists (select * from qestObjects where QestID = @QestID and Property = @baseProperty+convert(nvarchar(10),@position+@counter))
			begin
				insert into @qestObjects (QestID,QestActive,QestExtra,Property,value) select QestID,QestActive,QestExtra,@Property,Value from qestObjects where QestID = @QestID and Property = @baseProperty+convert(nvarchar(10),@position+@counter);
				set @Property = @baseProperty+convert(nvarchar(10),@position+@counter);
				set @counter = @counter+1;
			end

			if @printQueries = 1
			begin
				select 'update qestObjects set value = '''+replace(n.[Value],'''','''''')+''' where QestID = '+convert(nvarchar(10),n.QestID)+' and Property = '''+n.Property+''';'
				from @qestObjects n
				inner join qestObjects c on c.QestID = n.QestID and c.Property = n.Property

				--delete the last record
				select 'delete from qestObjects where QestID = '+convert(nvarchar(10),@QestID)+' and Property = '''+@Property+'''';
			end

			if @executeQueries = 1
			begin
				-- update existing properties
				update c
				set c.Value = n.value
				from @qestObjects n
				inner join qestObjects c on c.QestID = n.QestID and c.Property = n.Property

				--delete the last record
				delete from qestObjects where QestID = @QestID and Property = @Property;
			end
		end
GO

begin tran
													   					   
	-- update Gauge Make to Gauge Make/Model					   					   
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong1', @value = 'FieldName=GaugeMakeModel;Prompt=Gauge Make/Model;IsCommon=T;|';
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong1', @value = 'FieldName=GaugeMakeModel;Prompt=Gauge Make/model;IsCommon=T|';

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong1', @value = 'FieldName=GaugeMakeModel;Prompt=Gauge Make/Model;IsCommon=T;|';
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong1', @value = 'FieldName=GaugeMakeModel;Prompt=Gauge Make/Model;IsCommon=T|';

	-- remove Gauge model
	execute temp_RemoveObjectProperty @printqueries = 0,@executequeries = 1,@Qestid = 117062,@Property = 'RoadWOResultsFieldsLong3',@value = 'FieldName=GaugeModelNo;Prompt=Gauge Model;IsCommon=T;|'
	execute temp_RemoveObjectProperty @printqueries = 0,@executequeries = 1,@Qestid = 117062,@Property = 'WOResultsFieldsLong3',@value = 'FieldName=GaugeModelNo;Prompt=Gauge Model;IsCommon=T;|'

	execute temp_RemoveObjectProperty @printqueries = 0,@executequeries = 1,@Qestid = 117018,@Property = 'RoadWOResultsFieldsLong3',@value = 'FieldName=GaugeModelNo;Prompt=Gauge Model;IsCommon=T;|'
	execute temp_RemoveObjectProperty @printqueries = 0,@executequeries = 1,@Qestid = 117018,@Property = 'WOResultsFieldsLong3',@value = 'FieldName=GaugeModelNo;Prompt=Gauge Model;IsCommon=T;|'


	-- change MLD method to Moisture Standard Count
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong3',@value = 'FieldName=GaugeSerialNo;Prompt=Gauge Serial;IsCommon=T|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong3',@value = 'FieldName=GaugeSerialNo;Prompt=Gauge Serial;IsCommon=T|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong3',@value = 'FieldName=GaugeSerialNo;Prompt=Gauge Serial;IsCommon=T|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong3',@value = 'FieldName=GaugeSerialNo;Prompt=Gauge Serial;IsCommon=T|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong4',@value = 'FieldName=DensityStandardCount;Prompt=Density Standard Count;ValueFormat=0;IsCommon=T;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong4',@value = 'FieldName=DensityStandardCount;Prompt=Density Standard Count;ValueFormat=0;IsCommon=T;|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong4',@value = 'FieldName=DensityStandardCount;Prompt=Density Standard Count;ValueFormat=0;IsCommon=T;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong4',@value = 'FieldName=DensityStandardCount;Prompt=Density Standard Count;ValueFormat=0;IsCommon=T;|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong5',@value = 'FieldName=MoistureStandardCount;Prompt=Moisture Standard Count;ValueFormat=0;IsCommon=T;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong5',@value = 'FieldName=MoistureStandardCount;Prompt=Moisture Standard Count;ValueFormat=0;IsCommon=T;|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'RoadWOResultsFieldsLong5',@value = 'FieldName=MoistureStandardCount;Prompt=Moisture Standard Count;ValueFormat=0;IsCommon=T;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property = 'WOResultsFieldsLong5',@value = 'FieldName=MoistureStandardCount;Prompt=Moisture Standard Count;ValueFormat=0;IsCommon=T;|'

	-- changes from CR 2184
	delete from qestObjects where qestid = 117025 and Property ='PageFooterType'; insert into qestObjects(QestID,QestActive,Property,Value)values(117025,1,'PageFooterType','CommentsAndLegend');
	execute temp_AddObjectProperty @newProperty = 1,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong18', @value = 'FieldName=All;Prompt=Results;SpecificationNoteField;LimitFieldName=RelativeCompaction;Width=750;FieldIsReal=F;ValueStyle=font-size: 9\;font-family: Arial\;font-weight: normal\;;|'
	execute temp_AddObjectProperty @newProperty = 1,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong17', @value = 'FieldName=All;Prompt=Results;SpecificationNoteField;LimitFieldName=RelativeCompaction;Width=750;FieldIsReal=F;ValueStyle=font-size: 9\;font-family: Arial\;font-weight: normal\;;|'

	execute temp_AddObjectProperty @newProperty = 1,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong18', @value = 'FieldName=All;Prompt=Results;SpecificationNoteField;LimitFieldName=RelativeCompaction;Width=750;FieldIsReal=F;ValueStyle=font-size: 9\;font-family: Arial\;font-weight: normal\;;|'
	execute temp_AddObjectProperty @newProperty = 1,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong17', @value = 'FieldName=All;Prompt=Results;SpecificationNoteField;LimitFieldName=RelativeCompaction;Width=750;FieldIsReal=F;ValueStyle=font-size: 9\;font-family: Arial\;font-weight: normal\;;|'

	-- add % sign to the limit field.
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong16', @value = 'FieldName=RelativeCompaction;Prompt=Limit\\n(%);LimitField;Width=800;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117018,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong16', @value = 'FieldName=RelativeCompaction;Prompt=Limit\\n(%);LimitField;Width=800;|'

	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='RoadWOResultsFieldsLong16', @value = 'FieldName=RelativeCompaction;Prompt=Limit\\n(%);LimitField;Width=800;|'
	execute temp_AddObjectProperty @newProperty = 0,@printQueries= 0,@executeQueries = 1,@QestID = 117062,@QestActive= 1,@QestExtra = 0,@Property ='WOResultsFieldsLong16', @value = 'FieldName=RelativeCompaction;Prompt=Limit\\n(%);LimitField;Width=800;|'


	update qestObjects set Value='FieldName=RelativeCompaction;PrintIfNonNull=T;Prompt=Comp\\n(%);ValueFormat=0.0;UseMySpec;Width=500;LimitFieldName=RelativeCompaction;|' where Property='WOResultsFieldsLong15' and QestID=117062
	update qestObjects set Value='FieldName=RelativeCompaction;PrintIfNonNull=T;Prompt=Comp\\n(%);ValueFormat=0.0;UseMySpec;Width=500;LimitFieldName=RelativeCompaction;|' where Property='WOResultsFieldsLong15' and QestID=117018

commit

-- Stored procedure for adding Qest Object Properties
IF OBJECT_ID('[dbo].[temp_AddObjectProperty]') is not null
BEGIN
    DROP PROCEDURE [dbo].[temp_AddObjectProperty]
END
GO

IF OBJECT_ID('[dbo].[temp_RemoveObjectProperty]') is not null
BEGIN
    DROP PROCEDURE [dbo].[temp_RemoveObjectProperty]
END
GO
