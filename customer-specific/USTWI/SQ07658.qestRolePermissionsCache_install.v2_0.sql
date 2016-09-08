-------------------------------------------------------------------------
-- SQ07658 Performance Improvement - Install qestRolePermissionsCache
-- Logged as Bug 5442, expected general release in QESTLab 4.1.2200
--
-- Changes the way QESTLab performs permissions lookups, improving
-- performance on these lookups by over 90%
--
-- Database: QESTLab
-- Created By: Gavin Schultz-Ohkubo
-- Created Date: 26 February 2016
-- Last Modified By: Gavin Schultz-Ohkubo
-- Last Modified: 28 February 2016
-- 
-- Version: 2.0
-- Change Log
--		1.0		Original Version
--		2.0		Incorporates changes similar to those made to Qest_IsPermitted in SQ05446
--
-- Repeatability: Safe
-- Re-run Requirement: Once-off
-------------------------------------------------------------------------


if exists (select 1 from information_schema.tables t where t.table_name = 'qestRolePermissionsCache' and t.table_schema = 'dbo')
begin
  drop table dbo.qestRolePermissionsCache
end
go

create table dbo.qestRolePermissionsCache
(
  PersonID int not null,
  ActivityID int not null,
  LocationID int not null,
  InstanceID nvarchar(255) not null,
  PermissionMap int null,
  LastChecked datetime not null
)
go

create unique clustered index PK_qestRolePermissionsCache on dbo.qestRolePermissionsCache
(
  PersonID asc,
  ActivityID asc,
  LocationID asc,
  InstanceID asc
)
go

create nonclustered index IX_qestRolePermissionsCache_LastChecked on dbo.qestRolePermissionsCache
(
  LastChecked asc,
  PersonID asc
)
go

if exists (select 1 from information_schema.routines r where r.routine_name = 'qest_InvalidatePermissionsCache' and r.routine_schema = 'dbo')
begin
  drop proc dbo.qest_InvalidatePermissionsCache
end
go

create procedure dbo.qest_InvalidatePermissionsCache
  @MaximumAgeInSeconds int = 0,
  @PersonID int = 0
as
delete from dbo.qestRolePermissionsCache
where LastChecked <= DATEADD(SECOND, -@MaximumAgeInSeconds, GETDATE())
and (PersonID = @PersonID or @PersonID = 0)
go

if exists (select 1 from information_schema.routines r where r.routine_name = 'qest_GetPermission' and r.routine_schema = 'dbo')
begin
  drop proc dbo.qest_GetPermission
end
go

CREATE PROCEDURE [dbo].[qest_GetPermission] @PersonID int, @ActivityID int, @LocationID int, @InstanceID nvarchar(255) = ''
AS
declare @Result int

-- Check the cache for a result (and set the LastChecked at the same time)
update qestRolePermissionsCache
set LastChecked = GETDATE(),
  @Result = PermissionMap
from qestRolePermissionsCache
where PersonID = @PersonID
and ActivityID = @ActivityID
and LocationID = @LocationID
and InstanceID = @InstanceID

if @@ROWCOUNT = 1
begin
  select @Result
  return
end

IF @InstanceID = ''
BEGIN
  SELECT @Result = ISNULL(@Result,0)|ISNULL(PermissionMap,0)
  FROM RolePermissions AS perm
  WHERE 
    perm.ActivityID in (
      SELECT a2.QestUniqueID
      FROM Activities a1
        INNER JOIN Activities a2 ON (a1.Lft BETWEEN a2.Lft AND a2.Rgt)
      WHERE a1.QestUniqueID = @ActivityID
    )
    AND perm.RoleID in (
      SELECT map.RoleID FROM PeopleRolesMapping map WHERE map.PersonID = @PersonID
    )
    AND (@LocationID = 0 OR perm.LocationID in (
      SELECT l2.QestUniqueID
      FROM Laboratory l1
        INNER JOIN Laboratory l2 ON (l1.Lft BETWEEN l2.Lft AND l2.Rgt)
      WHERE l1.QestUniqueID = @LocationID
    ))
  AND (perm.InstanceID = '')
END
ELSE
BEGIN
  SELECT @Result = ISNULL(@Result,0)|ISNULL(PermissionMap,0)
  FROM RolePermissions AS perm
  WHERE 
    perm.ActivityID in (
      SELECT a2.QestUniqueID
      FROM Activities a1
        INNER JOIN Activities a2 ON (a1.Lft BETWEEN a2.Lft AND a2.Rgt)
      WHERE a1.QestUniqueID = @ActivityID
    )
    AND perm.RoleID in (
      SELECT map.RoleID FROM PeopleRolesMapping map WHERE map.PersonID = @PersonID
    )
    AND (@LocationID = 0 OR perm.LocationID in (
      SELECT l2.QestUniqueID
      FROM Laboratory l1
        INNER JOIN Laboratory l2 ON (l1.Lft BETWEEN l2.Lft AND l2.Rgt)
      WHERE l1.QestUniqueID = @LocationID
    ))
    AND (perm.InstanceID = '' OR perm.InstanceID = @InstanceID)
END

-- update cache
if @PersonID is not null and @ActivityID is not null and @LocationID is not null and @InstanceID is not null
begin
  insert into dbo.qestRolePermissionsCache (PersonID, ActivityID, LocationID, InstanceID, PermissionMap, LastChecked)
  select @PersonID, @ActivityID, @LocationID, @InstanceID, @Result, GETDATE()
  where not exists (
    select 1 from qestRolePermissionsCache
    where PersonID = @PersonID
    and ActivityID = @ActivityID
    and LocationID = @LocationID
    and InstanceID = @InstanceID
  )
end

SELECT @Result
GO

if object_id('dbo.TR_SessionConnections_InvalidatePermissionsCache', 'TR') is not null
begin
  drop trigger TR_SessionConnections_InvalidatePermissionsCache
end
go

create trigger TR_SessionConnections_InvalidatePermissionsCache
on dbo.SessionConnections after delete
as
  declare @PersonID int
  select @PersonID = u.PersonID
  from deleted d
    inner join dbo.Users u on u.QestUniqueID = d.UserID

  if @PersonID is not null
  begin
    exec dbo.qest_InvalidatePermissionsCache 0, @PersonID
  end
go

if exists (select 1 from information_schema.routines r where r.routine_name = 'qest_IsPermitted' and r.routine_schema = 'dbo')
begin
  drop proc dbo.qest_IsPermitted
end
go

CREATE PROCEDURE [dbo].[qest_IsPermitted] @PersonID int, @ActivityID int, @LocationID int, @InstanceID nvarchar(255) = '', @PermissionType int = 0x0
AS
--empty table so that we can easily return an empty result set.
DECLARE @e TABLE (c bit);
DECLARE @PermissionMap int

-- Check the cache for a result (and set the LastChecked at the same time)
update qestRolePermissionsCache
set LastChecked = GETDATE(),
  @PermissionMap = PermissionMap
from qestRolePermissionsCache
where PersonID = @PersonID
and ActivityID = @ActivityID
and LocationID = @LocationID
and InstanceID = @InstanceID

if @@ROWCOUNT = 1
begin
  if (@PermissionMap & @PermissionType) > 0
    select 1
  else
    select 0 from @e
  return
end

--to get a better query plan when no @InstanceID parameter is supplied (which is very common), we essentially have 
--two identical branches, one with the check on @InstanceID, and one without it.
IF @InstanceID = ''
BEGIN
  SELECT @PermissionMap = ISNULL(@PermissionMap,0)|ISNULL(PermissionMap,0)
  FROM RolePermissions AS perm
  WHERE 
    perm.ActivityID in (
      SELECT a2.QestUniqueID
      FROM Activities a1
        INNER JOIN Activities a2 ON (a1.Lft BETWEEN a2.Lft AND a2.Rgt)
      WHERE a1.QestUniqueID = @ActivityID
    )
    AND perm.RoleID in (
      SELECT map.RoleID FROM PeopleRolesMapping map WHERE map.PersonID = @PersonID
    )
    AND (@LocationID = 0 OR perm.LocationID in (
      SELECT l2.QestUniqueID
      FROM Laboratory l1
        INNER JOIN Laboratory l2 ON (l1.Lft BETWEEN l2.Lft AND l2.Rgt)
      WHERE l1.QestUniqueID = @LocationID
    ))
	AND (perm.InstanceID = '')
  
  IF (@PermissionMap & @PermissionType) > 0
    SELECT 1
  ELSE
    SELECT 0 FROM @e
END
ELSE
BEGIN
  SELECT @PermissionMap = ISNULL(@PermissionMap,0)|ISNULL(PermissionMap,0)
  FROM RolePermissions AS perm
  WHERE 
    perm.ActivityID in (
      SELECT a2.QestUniqueID
      FROM Activities a1
        INNER JOIN Activities a2 ON (a1.Lft BETWEEN a2.Lft AND a2.Rgt)
      WHERE a1.QestUniqueID = @ActivityID
    )
    AND perm.RoleID in (
      SELECT map.RoleID FROM PeopleRolesMapping map WHERE map.PersonID = @PersonID
    )
    AND (@LocationID = 0 OR perm.LocationID in (
      SELECT l2.QestUniqueID
      FROM Laboratory l1
        INNER JOIN Laboratory l2 ON (l1.Lft BETWEEN l2.Lft AND l2.Rgt)
      WHERE l1.QestUniqueID = @LocationID
    ))
    AND (PermissionMap & @PermissionType) > 0
    AND (perm.InstanceID = '' OR perm.InstanceID = @InstanceID)
  
  IF (@PermissionMap & @PermissionType) > 0
    SELECT 1 
  ELSE
    SELECT 0 FROM @e
END

-- update cache
if @PersonID is not null and @ActivityID is not null and @LocationID is not null and @InstanceID is not null
begin
  insert into dbo.qestRolePermissionsCache (PersonID, ActivityID, LocationID, InstanceID, PermissionMap, LastChecked)
  select @PersonID, @ActivityID, @LocationID, @InstanceID, @PermissionMap, GETDATE()
  where not exists (
    select 1 from qestRolePermissionsCache
    where PersonID = @PersonID
    and ActivityID = @ActivityID
    and LocationID = @LocationID
    and InstanceID = @InstanceID
  )
end
GO
