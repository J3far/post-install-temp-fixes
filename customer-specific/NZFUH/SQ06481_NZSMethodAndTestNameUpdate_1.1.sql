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
-- Last Modified By: Salih AL Rashid
-- Last Modified: 22 OCT 2015
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--  1.1 add query to update value of RevisionYear property to 2015 
--		for all the selected tests
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------


declare @qestIDofRecords table (QestID int)
declare @RecordsToUpdate table (QestID int,OldTestName varchar(200),OldMethod varchar(200),NewTestName varchar(200),NewMethod varchar(200))
declare @sql nvarchar(max)
declare @sql2 nvarchar(max)
declare @commit bit = 'false'

insert into @qestIDofRecords select QESTID from qestObjects
where Property in ('Name','Method') and value like '%NZS 4407:1991%'
group by QestID
order by QestID

set nocount on
declare update_tables cursor for 
	select

		'	
			Update qestObjects
			SET Value = REPLACE(Value,''NZS 4407:1991'',''NZS 4407:2015'')
			where QestID = ' + CONVERT(nvarchar(20),QestID) + '
			AND (property in (''Name'', ''Method''))

			Update qestObjects
			SET Value = ''2015''
			where QestID = ' + CONVERT(nvarchar(20),QestID) + '
			AND property = ''RevisionYear''
		'
		, ' Select distinct qo.qestID , qo1.Value,qo2.Value,'''','''' from qestObjects qo
			INNER JOIN qestObjects qo1 ON qo1.QestID = qo.QestID and qo1.Property = ''Name''
			LEFT JOIN qestObjects qo2 ON qo2.QestID = qo.QestID and qo2.Property = ''Method''
			where qo.qestID =' + CONVERT(nvarchar(20),QestID) 
	from 
		@qestIDofRecords

open update_tables

fetch next from update_tables into @sql, @sql2

if (@@FETCH_STATUS = -1)
	raiserror('There are no rows to update', 16, 2);
if (@@FETCH_STATUS = -2)
	raiserror('The row fetched is missing.', 16, 2);

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

declare @recordCount nvarchar(16) = cast((select count(*) from @qestIDofRecords) as nvarchar(16))

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

------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ07705
-- NZS Nuclear Field Density Test Number changes

-- This script updates the NZS nuclar density tests numbers:
-- 4.2.1 to 4.2 and
-- 4.2.2 to 4.3

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 22/02/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Once-off
------------------------------------------------------------------------------------------------------------------------------------------------
update qestobjects set value = 'NZS 4407:2015 Test 4.2' where qestid = 10331 and property = 'Method'
update qestobjects set value = 'Nuclear Field Density [NZS 4407:2015 Test 4.2]' where qestid = 10331 and property = 'Name'

update qestobjects set value = 'NZS 4407:2015 Test 4.3' where qestid = 10332 and property = 'Method'
update qestobjects set value = 'Nuclear Field Density [NZS 4407:2015 Test 4.3]' where qestid = 10332 and property = 'Name'
