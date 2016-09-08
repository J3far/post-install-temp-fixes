------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ08424
-- qest_getsummaryReportHeaderFields

-- This script modifies the qest_getsummaryReportHeaderFields stored procedure which used in the management reports header to return more details 
-- such as _INTERFACE_PermitNo and _INTERFACE_OSHPDNo

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 01/09/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Not sure if it needs to run after every DB update but it is safe to re-run. So lets run after every DB update for now.
------------------------------------------------------------------------------------------------------------------------------------------------
if exists (select * from sys.procedures where name = 'qest_getsummaryReportHeaderFields')
	DROP PROCEDURE [dbo].[qest_getsummaryReportHeaderFields]
GO

CREATE proc [dbo].[qest_getsummaryReportHeaderFields]
  @sql as nvarchar(max)
as

set nocount on;
declare @results table(ClientName nvarchar(200), ProjectName nvarchar(200),DateTested date)
begin try
  begin transaction
  
  declare @tbl nvarchar(40);
  declare @NewLine char(2) = char(13)+char(10);

  set @tbl = '[' + CAST(newid() as nvarchar(36)) + ']';
  --in an attempt to handle SQL queries that have an order by clause ... use "select top 100 percent"... this is pretty nasty.
  if @sql like 'select %order by %' and @sql not like 'select top%' set @sql = 'select top (100) percent ' + SUBSTRING(@sql, LEN('select ') + 1, 2147483647);
  set @sql = 'select distinct UPPER(' + @tbl + '.ClientName), UPPER(' + @tbl + '.ProjectName),'+
  (case when @sql like '%DateTested%' then @tbl+'.DateTested' else 'null AS DateTested' end) 
  +' from ('+ @sql + ') as' + @tbl + ';'
  
  insert into @results (ClientName, ProjectName,DateTested)
    exec sp_executesql @sql, N'';
  declare @count int;
  select @count = count(*) from (select distinct *  from @results) res;
    
  if @count = 1
  begin
    select top 1 'Permit No:'+coalesce(lp._INTERFACE_PermitNo,'')+@NewLine+'OSHPD:'+coalesce(lp._INTERFACE_OSHPDNo,'')+@NewLine+'DSA File#:'+coalesce(lp._INTERFACE_DSA_File_No,'')+@NewLine+'DSA App:'+coalesce(lp._INTERFACE_DSA_Appl_No,'') ClientName, 
	'Project Code: '+coalesce(lp.ProjectCode,'') +@NewLine+'Project Name: ' + coalesce(rs.ProjectName,'')+@NewLine+'Test Date: '+coalesce(convert(nvarchar(15), rs.DateTested,101),'') ProjectName 
	from @results rs
	left join ListProject lp on rs.ProjectName = lp.ProjectName and rs.ClientName = lp.ClientName
  end
  else
  begin
    raiserror('More than one client/project in result set', 10, 1);
    select ClientName = cast(null as nvarchar(200)), ProjectName = cast(null as nvarchar(200))
  end
  
  rollback
end try
begin catch
  declare @error_message nvarchar(max);
  select @error_message = ERROR_MESSAGE();
  raiserror('%s', 10, 1, @error_message);
  raiserror('SQL: %s', 10, 1, @sql);
  rollback
  select ClientName = cast(null as nvarchar(200)), ProjectName = cast(null as nvarchar(200))
end catch

GO