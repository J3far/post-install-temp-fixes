-------------------------------------------------------------------------
-- Pre-Install Script
-- Clean up QestReverseLookup
--
-- Database: QESTLab
-- Created By: Christopher Kerr
-- Created Date: 25 August 2016
-- Last Modified By: Christopher Kerr
-- Last Modified: 25 August 2016
-- 
-- Version: 1.0
-- Change Log
--		1.0		Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Before database upgrades
-------------------------------------------------------------------------

IF EXISTS(SELECT 1 FROM qestReverseLookup WHERE QestUniqueID = 0)
begin
	raiserror('QestReverseLookup contains records with QestUniqueID = 0. Attempting repair.', 1, 0) with nowait

	begin transaction

	declare curSQL cursor fast_forward for
	select 'update rl set QestUniqueID = src.QestUniqueID from [dbo].[qestReverseLookup] rl inner join ' + quotename(t.table_name) + ' src on rl.QestUUID = src.QestUUID where rl.QestUniqueID = 0'
	from INFORMATION_SCHEMA.TABLES t
	where exists (
	select *
		from qestReverseLookup rl
		inner join qestObjects o on rl.QestID = o.QestID and o.Property = 'TableName'
		where rl.QestUniqueID = 0
		and o.Value = t.TABLE_NAME
	)
	and t.TABLE_SCHEMA = 'dbo'
	order by t.TABLE_NAME

	open curSQL
	declare @sql_statement nvarchar(max)
	fetch next from curSQL into @sql_statement

	while @@FETCH_STATUS = 0
	begin
		exec sp_executesql @sql_statement
		fetch next from curSQL into @sql_statement
	end

	close curSQL
	deallocate curSQL

	commit transaction
end

IF EXISTS(SELECT 1 FROM qestReverseLookup WHERE QestUniqueID = 0)
BEGIN
	raiserror('QestReverseLookup still contains records with QestUniqueID = 0 after repair. Deleting invalid records.', 1, 0) with nowait
	
	begin transaction
	delete from QestReverseLookup where QestUniqueID = 0
	commit transaction
END


-- VALIDATION: Check for duplicate QestID, QestUniqueID pairs
IF EXISTS(SELECT 1 FROM qestReverseLookup GROUP BY QestUniqueID, QestID HAVING COUNT(*) > 1)
BEGIN
	declare @number_of_duplicates int;
	select @number_of_duplicates = count(*) from (SELECT 1 X FROM qestReverseLookup GROUP BY QestUniqueID, QestID HAVING COUNT(*) > 1) X
	RAISERROR ('qestReverseLookup corruption detected. %d Duplicate QestID/QestUniqueID pairs found.
Please contact Spectra QEST Support.
', 16, 0, @number_of_duplicates)
END
ELSE
BEGIN
		print 'QestReverseLookup is now ready for QESTNET.Upgrade'
END