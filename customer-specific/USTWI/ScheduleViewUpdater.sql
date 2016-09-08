declare @QPUID int

select @QPUID = QestUniqueID 
from qestDisplayObjectCollection 
where QestID = 101 and Name = 'Schedule'

--select * from qestDisplayObjectDetails where QestUniqueParentID = @QPUID order by displayorder

-- Sets the "Date" and "Requirements" fields to editable
update qestDisplayObjectDetails
set [readonly] = 0
where QestUniqueParentID = @QPUID and FieldName in ('WorkDate', 'ClientRequirements')

-- Sets the "Requirements" field to a multiline text box and changes the Caption to 'Work Instructions'
update qestDisplayObjectDetails
set DisplayType = 6, Caption = 'Work Instructions'
where QestUniqueParentID = @QPUID and FieldName in ('ClientRequirements')

delete from qestDisplayObjectDetails
where QestUniqueParentID = @QPUID and FieldName in ('ProjectCode')

insert into qestDisplayObjectDetails
(QestUniqueParentID,FieldName,Caption,DisplayOrder,FormatString,DisplayType,[ReadOnly],AutoFill,AdditionalData,Hidden,Width,MaxLength)
values
(@QPUID,'ProjectCode','Project No.',5,'',0,1,0,'',0,800,20)

update qestDisplayObjectDetails set DisplayOrder = 11 where FieldName = 'ClientName' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 10 where FieldName = 'ClientRequirements' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 9 where FieldName = 'FinishTime' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 8 where FieldName = 'Duration' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 7 where FieldName = 'StartTime' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 6 where FieldName = 'PersonName' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 5 where FieldName = 'PersonCode' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 4 where FieldName = 'Location' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 3 where FieldName = 'ProjectName' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 2 where FieldName = 'ProjectCode' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 1 where FieldName = 'WorkDate' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set DisplayOrder = 0 where FieldName = 'WorkOrderID' and QestUniqueParentID = @QPUID

-- Hide these fields
update qestDisplayObjectDetails set Hidden = 1 where FieldName = 'PersonCode' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set Hidden = 1 where FieldName = 'Duration' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set Hidden = 1 where FieldName = 'FinishTime' and QestUniqueParentID = @QPUID

update qestDisplayObjectDetails set Width = 5600 where FieldName = 'ProjectName' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set Width = 2200 where FieldName = 'ProjectCode' and QestUniqueParentID = @QPUID
update qestDisplayObjectDetails set Width = 3400 where FieldName = 'PersonName' and QestUniqueParentID = @QPUID


--select ProjectCode from ListProject where len(ProjectCode) in (select max(len(ProjectCode)) from ListProject) -- ~1100 twips
--select ProjectName from ListProject where len(ProjectName) in (select max(len(ProjectName)) from ListProject) -- ~2560 twips
--select Name from People where len(Name) in (select max(len(Name)) from People) -- ~3160 twips
