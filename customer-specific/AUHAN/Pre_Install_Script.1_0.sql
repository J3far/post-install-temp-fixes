--------------------------------------------------------------------------------------------------------------
-- This script contains fixes that need to be applied to the database before running the QESTNet upgrade tool.

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 18/11/2015
-- Date Modified: 01/03/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version
--- 2.0 Added the qestReportmapping.testQestUUID & qestReportmapping.ReportQestUUID to the clan up process.

-- Repeatability: Safe
-- Re-Run Requirement: Once-off
--------------------------------------------------------------------------------------------------------------
set nocount on;

-- only apply changes if the databsae version is less than 4

-- get the cusrrent QL version (could use the QN version as well)
declare @qlVersion int = (select left(Value,1) from qestSystemValues where Name = 'DatabaseQestVersion')

-- if QL verion is  or higher then ignore
if @qlVersion >= 4 or (select count(*) from qestSystemValues where Name = 'cleanUUIDsIsRunOnce' and value = 'True') > 0 set noexec on; 

-- add a flag to the qestSystem values to avoid running this script mre than once.
if (select count(*) from qestSystemValues where Name = 'cleanUUIDsIsRunOnce') = 0
begin
	insert into qestSystemValues (name,Value) 
	select 'cleanUUIDsIsRunOnce','False';
end

declare @tablesToCheck table(tableName nvarchar(200));
declare @table nvarchar(200) = '';
declare @sql_to_execute nvarchar(max) = '';

-- get all the tables with QESTUUID on them
insert into @tablesToCheck (tableName)
select TABLE_NAME from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'QestUUID' and table_name not in ('People','TestConditions') order by TABLE_NAME

-- clean the uuids
while (select count(*) from @tablesToCheck) > 0
begin
	select top 1 @table = TableName from @tablesToCheck;

	set @sql_to_execute = '
	if (select count(*) from '+@table+' where  QestUUID is not null) = 0 set noexec on;
	print ''Updating QestUUIDs on '+@table+', set to null ''
	update '+@table+' set QestUUID = null where QestUUID is not null;
		set noexec off;
	';
	execute sp_sqlexec @sql_to_execute

	delete from @tablesToCheck where tableName = @table
end

-- special cases
if exists (select * from information_schema.COLUMNS where TABLE_NAME = 'qestReverseLookup' and COLUMN_NAME = 'QestParentUUID')
	execute sp_sqlexec 'update qestReverseLookup set QestParentUUID = null where QestParentUUID is not null;'

if exists (select * from information_schema.COLUMNS where TABLE_NAME = 'qestReportMapping' and COLUMN_NAME = 'TestQestUUID')
	execute sp_sqlexec 'update qestReportMapping set TestQestUUID = null;'

if exists (select * from information_schema.COLUMNS where TABLE_NAME = 'qestReportMapping' and COLUMN_NAME = 'ReportQestUUID')
	execute sp_sqlexec 'update qestReportMapping set ReportQestUUID = null;'

update qestSystemValues set value = 'True' where name = 'cleanUUIDsIsRunOnce'

set noexec off;
go