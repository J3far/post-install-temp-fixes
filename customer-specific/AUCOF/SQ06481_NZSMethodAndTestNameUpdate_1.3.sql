-------------------------------------------------------------------------
-- SQ06481
-- NZ Test Method Update - NZS 4407 : 2015 to included in 4.1 Upgrade
-- 
-- This script will update Method and test properties on qestObjects
-- from 'NZS 4407:1991' to 'NZS 4407:2015'
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 15 OCT 2015

-- Last Modified By: Benny Thomas
-- Last Modified: 04 MAR 2016
-- 
-- Version: 1.2
-- Change LOG
--	1.0 Original Version
--  1.1 add query to update value of RevisionYear property to 2015 
--		for all the selected tests
--  1.2 [Jafar] Modified the script to update the results fields methods on the NZS tests as well.
-- 	1.3 [Benny] Modified script to make it SQL Server 2008 compatible

-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------


set nocount on
declare @qestIDofRecords table (QestID int)
declare @RecordsToUpdate table (QestID int,OldTestName varchar(200),OldMethod varchar(200),NewTestName varchar(200),NewMethod varchar(200))
declare @sql nvarchar(max)
declare @sql2 nvarchar(max)
declare @commit nvarchar(10)
set @commit = 'false'

insert into @qestIDofRecords select QESTID from qestObjects
where Property in ('Name','Method','ResultsFields') and value like '%NZS 4407:1991%'
group by QestID
order by QestID

declare update_tables cursor for 
	select

		'	
			Update qestObjects
			SET Value = REPLACE(Value,''NZS 4407:1991'',''NZS 4407:2015'')
			where QestID = ' + CONVERT(nvarchar(20),QestID) + '
			AND (property in (''Name'', ''Method'',''ResultsFields''))

			Update qestObjects
			SET Value = ''2015''
			where QestID = ' + CONVERT(nvarchar(20),QestID) + '
			AND property = ''RevisionYear''
		'
		, ' Select distinct qo.qestID , qo1.Value,qo2.Value,'''','''' from qestObjects qo
			INNER JOIN qestObjects qo1 ON qo1.QestID = qo.QestID and qo1.Property = ''Name''
			LEFT JOIN qestObjects qo2 ON qo2.QestID = qo.QestID and qo2.Property = ''Method''
			LEFT JOIN qestObjects qo3 ON qo3.QestID = qo.QestID and qo3.Property = ''ResultsFields''
			where qo.qestID =' + CONVERT(nvarchar(20),QestID) 
	from 
		@qestIDofRecords

open update_tables

fetch next from update_tables into @sql, @sql2

if (@@FETCH_STATUS = -1)
begin
	print'There are no rows to update';
	set noexec on;
end
if (@@FETCH_STATUS = -2)
begin
	print 'The row fetched is missing.';
	set noexec on;
end

while @@FETCH_STATUS = 0
begin

	if @commit = 'TRUE' begin
		execute sp_executesql @sql;
	end
	else begin 
		insert into @RecordsToUpdate
		execute sp_executesql @sql2;
	end

fetch next from update_tables into @sql, @sql2;
end

declare @recordCount nvarchar(16) 
set @recordCount = cast((select count(*) from @qestIDofRecords) as nvarchar(16))

if (@commit = 'TRUE' and @recordCount <> '0') begin
	print (char(10) + 'Updated ' + @recordCount + ' row' + case when @recordCount <> 1 then 's' else '' end)
end
else if (@commit = 'FALSE')
begin
	
	Update @RecordsToUpdate
	SET NewTestName = REPLACE(OldTestName,'NZS 4407:1991','NZS 4407:2015'), NewMethod = REPLACE(OldMethod,'NZS 4407:1991','NZS 4407:2015')
	select * from @RecordsToUpdate
	print (char(10) + 'There are ' + @recordCount + ' row' + case when @recordCount <> 1 then 's to update' else '' end)
end
set nocount off
close update_tables
deallocate update_tables
set noexec off;