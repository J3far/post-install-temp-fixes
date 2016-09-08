------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ08591
-- Suppress Field added to new Documents

-- This script updates qest_UserDocumentBaseInitialise procedure to prevent it from adding the SuppressSyncTrigger field to new user documents

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 23/06/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Re run after every database upgrade until issue is resolved.
------------------------------------------------------------------------------------------------------------------------------------------------

if exists (select * from sys.procedures where name = 'qest_UserDocumentBaseInitialise')
	DROP PROCEDURE [dbo].[qest_UserDocumentBaseInitialise]
GO

create proc [dbo].[qest_UserDocumentBaseInitialise] @QestID int = 0
as
set nocount on

declare @table_name nvarchar(128)
if not (@QestID = 0 or @QestID between 19000 and 19999)
begin
  raiserror(N'QestID parameter must be 0 to apply to all tables, or between 19000 and 19999 to target a specific user document.', 16, 1)
  return
end
else
begin
  select @table_name = Value from qestObjects where QestID = @QestID and Property = 'TableName'
end

declare @sqlexec table
(
  ID int not null identity(1,1),
  SQLText_TR_I_Drop nvarchar(4000) null,
  SQLText_TR_I_Create nvarchar(4000) null,
  SQLText_TR_U_Drop nvarchar(4000) null,
  SQLText_TR_U_Create nvarchar(4000) null,
  SQLText_TR_D_Drop nvarchar(4000) null,
  SQLText_TR_D_Create nvarchar(4000) null,
  SQLText_Insert nvarchar(4000) null,
  TableName nvarchar(128) not null
)

insert into @sqlexec (
  SQLText_TR_I_Drop, 
  SQLText_TR_I_Create, 
  SQLText_TR_U_Drop, 
  SQLText_TR_U_Create, 
  SQLText_TR_D_Drop, 
  SQLText_TR_D_Create, 
  SQLText_Insert, 
  TableName)
select 
  N'IF OBJECT_ID(''TR_' + qo_table.Value + '_TableSync_Insert'', ''TR'') IS NOT NULL
	  DROP TRIGGER TR_' + qo_table.Value + '_TableSync_Insert',
  N'CREATE TRIGGER TR_' + qo_table.Value + '_TableSync_Insert
  ON ' + qo_table.Value + ' AFTER INSERT
  AS
    set nocount on
    declare @rowcount int
    
    -- ensure this trigger is only activated by a direct SQL statement, and not by another trigger
    if trigger_nestlevel() > 1
      return;
    
    set identity_insert UserDocumentBase on;
    
    insert into UserDocumentBase (
      QestID,
      QestTier,
      QestParentID,
      QestUniqueParentID,
      QestUniqueID,
      QestComplete,
      QestCreatedBy,
      QestCreatedDate,
      QestModifiedBy,
      QestModifiedDate,
      QestOwnerLabNo,
      QestTestedBy,
      QestTestedDate,
      QestCheckedBy,
      QestCheckedDate,
      QestOutOfSpecification,
      QestSpecification,
      QestStatusFlags,
      QestUrgent,
      QestLabNo,
      QestUUID)
    select
      QestID,
      QestTier,
      QestParentID,
      QestUniqueParentID,
      QestUniqueID,
      QestComplete,
      QestCreatedBy,
      QestCreatedDate,
      QestModifiedBy,
      QestModifiedDate,
      QestOwnerLabNo,
      QestTestedBy,
      QestTestedDate,
      QestCheckedBy,
      QestCheckedDate,
      QestOutOfSpecification,
      QestSpecification,
      QestStatusFlags,
      QestUrgent,
      QestLabNo,
      QestUUID
    from inserted i
    where not exists (select 1 from UserDocumentBase udb where udb.QestUUID = i.QestUUID)
    and i.QestID between 19000 and 19999
    
    set @rowcount = @@ROWCOUNT
    if @rowcount > 0
      raiserror(N''Synced table UserDocumentBase from ' + qo_table.Value + ', %i records inserted.'', 0, 1, @rowcount)
      
    set identity_insert UserDocumentBase off;',
  N'IF OBJECT_ID(''TR_' + qo_table.Value + '_TableSync_Update'', ''TR'') IS NOT NULL
	  DROP TRIGGER TR_' + qo_table.Value + '_TableSync_Update',
  N'CREATE TRIGGER TR_' + qo_table.Value + '_TableSync_Update
  ON ' + qo_table.Value + ' AFTER UPDATE
  AS
    set nocount on
    declare @rowcount int

    -- ensure this trigger is only activated by a direct SQL statement, and not by another trigger
    if trigger_nestlevel() > 1
      return;

    update UserDocumentBase
    set QestID = i.QestID,
		    QestTier = i.QestTier,
        QestParentID = i.QestParentID,
        QestUniqueParentID = i.QestUniqueParentID,
        QestComplete = i.QestComplete,
        QestCreatedBy = i.QestCreatedBy,
        QestCreatedDate = i.QestCreatedDate,
        QestModifiedBy = i.QestModifiedBy,
        QestModifiedDate = i.QestModifiedDate,
        QestOwnerLabNo = i.QestOwnerLabNo,
        QestTestedBy = i.QestTestedBy,
        QestTestedDate = i.QestTestedDate,
        QestCheckedBy = i.QestCheckedBy,
        QestCheckedDate = i.QestCheckedDate,
        QestOutOfSpecification = i.QestOutOfSpecification,
        QestSpecification = i.QestSpecification,
        QestStatusFlags = i.QestStatusFlags,
        QestUrgent = i.QestUrgent,
        QestLabNo = i.QestLabNo,
        QestUUID = i.QestUUID
    from inserted i
    where UserDocumentBase.QestUUID = i.QestUUID 
    and i.QestID between 19000 and 19999
    
    set @rowcount = @@ROWCOUNT
    if @rowcount > 0
      raiserror(N''Synced table UserDocumentBase from ' + qo_table.Value + ', %i records updated.'', 0, 1, @rowcount)',
  N'IF OBJECT_ID(''TR_' + qo_table.Value + '_TableSync_Delete'', ''TR'') IS NOT NULL
	  DROP TRIGGER TR_' + qo_table.Value + '_TableSync_Delete',
  N'CREATE TRIGGER TR_' + qo_table.Value + '_TableSync_Delete
  ON ' + qo_table.Value + ' AFTER DELETE
  AS
    set nocount on
    declare @rowcount int
    
    delete UserDocumentBase
    from deleted d
    where UserDocumentBase.QestUUID = d.QestUUID
    and d.QestID between 19000 and 19999
    
    set @rowcount = @@ROWCOUNT
    if @rowcount > 0
      raiserror(N''Synced table UserDocumentBase from ' + qo_table.Value + ', %i records deleted.'', 0, 1, @rowcount)',
  N'set identity_insert UserDocumentBase on;
  
    disable trigger TR_UserDocumentBase_TableSync_Insert ON UserDocumentBase;
  
    insert into UserDocumentBase (
    QestID,
    QestTier,
    QestParentID,
    QestUniqueParentID,
    QestUniqueID,
    QestComplete,
    QestCreatedBy,
    QestCreatedDate,
    QestModifiedBy,
    QestModifiedDate,
    QestOwnerLabNo,
    QestTestedBy,
    QestTestedDate,
    QestCheckedBy,
    QestCheckedDate,
    QestOutOfSpecification,
    QestSpecification,
    QestStatusFlags,
    QestUrgent,
    QestLabNo,
    QestUUID)
  select
    QestID,
    QestTier,
    QestParentID,
    QestUniqueParentID,
    QestUniqueID,
    QestComplete,
    QestCreatedBy,
    QestCreatedDate,
    QestModifiedBy,
    QestModifiedDate,
    QestOwnerLabNo,
    QestTestedBy,
    QestTestedDate,
    QestCheckedBy,
    QestCheckedDate,
    QestOutOfSpecification,
    QestSpecification,
    QestStatusFlags,
    QestUrgent,
    QestLabNo,
    QestUUID
  from ' + qo_table.Value + N' u
  where not exists (select 1 from UserDocumentBase udb where udb.QestUUID = u.QestUUID)
  and u.QestID between 19000 and 19999;
  
  select @rows = @@rowcount;

  enable trigger TR_UserDocumentBase_TableSync_Insert ON UserDocumentBase;
  set identity_insert UserDocumentBase off',
  qo_table.Value
from qestObjects qo_table
where qo_table.QestID between 19000 and 19999
and qo_table.Property = 'TableName'
and (@QestID = 0 or qo_table.QestID = @QestID)

declare @id int
declare @sql_insert nvarchar(4000)
declare @sql_tr_i_drop nvarchar(4000)
declare @sql_tr_i_create nvarchar(4000)
declare @sql_tr_u_drop nvarchar(4000)
declare @sql_tr_u_create nvarchar(4000)
declare @sql_tr_d_drop nvarchar(4000)
declare @sql_tr_d_create nvarchar(4000)
declare @rowcount int
while (select count(*) from @sqlexec s) > 0
begin
  select top 1 
    @id = ID, 
    @sql_tr_i_drop = SQLText_TR_I_Drop,
    @sql_tr_i_create = SQLText_TR_I_Create,
    @sql_tr_u_drop = SQLText_TR_U_Drop,
    @sql_tr_u_create = SQLText_TR_U_Create,
    @sql_tr_d_drop = SQLText_TR_D_Drop,
    @sql_tr_d_create = SQLText_TR_D_Create,
    @sql_insert = SQLText_Insert, 
    @table_name = TableName 
  from @sqlexec
  
  exec sp_executesql @sql_tr_i_drop
  exec sp_executesql @sql_tr_i_create
  exec sp_executesql @sql_tr_u_drop
  exec sp_executesql @sql_tr_u_create
  exec sp_executesql @sql_tr_d_drop
  exec sp_executesql @sql_tr_d_create
  exec sp_executesql @sql_insert, N'@rows int OUTPUT', @rows = @rowcount OUTPUT;
  
  raiserror(N'Syncing records from table %s to UserDocumentBase, %i records inserted.', 0, 1, @table_name, @rowcount)
  delete from @sqlexec where ID = @id
end

GO


