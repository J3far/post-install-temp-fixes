-------------------------------------------------------------------------
-- SQ07792
-- Drop SuppressSyncTrigger column
-- 
-- This script removes the SuppressSyncTrigger column from all
-- tables in order to prevent it from appearing in the user document
-- maintenance window.
-- 
-- Created By: Gavin Schultz-Ohkubo
-- Created Date: 3 Mar 2016
-- Last Modified By: 
-- Last Modified:
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Re-run after QESTNET.Upgrade has been run
--    NOTE: a later version of QESTNET / QESTNET.Upgrade / QESTLab will 
--    prevent the column from being created, at which time this script no
--    longer needs to be run.
--        
-------------------------------------------------------------------------

if exists (select 1 from information_schema.routines r where r.routine_name = 'qest_DropSuppressSyncTrigger' and r.routine_schema = 'dbo')
begin
  drop proc dbo.qest_DropSuppressSyncTrigger
end
go

create proc dbo.qest_DropSuppressSyncTrigger
as
declare @sql nvarchar(4000)
declare @tablename nvarchar(500)

-- Throw an error rather than replace a potentially newer version of this core procedure. This proc is created early in the QESTNET.Upgrade process
if not exists (select 1 from information_schema.routines where routine_name = 'qest_DropDefault' and specific_schema = 'dbo')
begin
  raiserror('This script cannot be run because the stored procedure qest_DropDefault does not exists. Please ensure that QESTNET.Upgrade has been run on the QESTLab database first.', 16, 1)
  return
end

if exists (select 1 from information_schema.columns where table_name = 'UserDocumentBase' and column_name = 'SuppressSyncTrigger' and table_schema = 'dbo')
begin
	alter table dbo.UserDocumentBase drop column SuppressSyncTrigger
end

declare userdoc_cursor cursor local for
select c.table_name 
from information_schema.columns c 
where table_name like 'UserDocument[0-9]%' 
and column_name = 'SuppressSyncTrigger' 
and table_schema = 'dbo'

open userdoc_cursor
fetch next from userdoc_cursor into @tablename

while @@fetch_status = 0
begin
  raiserror('Removing SuppressSyncTrigger from %s', 0, 1, @tablename)

  set @sql = 'qest_DropDefault ''' + @tablename + ''', ''SuppressSyncTrigger'''
  exec sp_executesql @sql

  set @sql = 'alter table dbo.[' + @tablename + '] drop column SuppressSyncTrigger'
  exec sp_executesql @sql
  
  fetch next from userdoc_cursor into @tablename
end

close userdoc_cursor
deallocate userdoc_cursor
go

begin tran
exec dbo.qest_DropSuppressSyncTrigger
drop proc dbo.qest_DropSuppressSyncTrigger
commit
go
