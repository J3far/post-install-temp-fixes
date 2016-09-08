SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('qest_Filter_DefaultWithSamples', 'view') IS NOT NULL 
DROP VIEW qest_Filter_DefaultWithSamples 
GO
CREATE VIEW [dbo].[qest_Filter_DefaultWithSamples]
AS
SELECT    w.QestID, w.QestUniqueID, w.QestUniqueParentID, w.QestParentId, w.QestOwnerLabNo, w.ProjectOwnerCode, w.TechnicianCode, w.ClientCode, w.ProjectCode, w.WorkOrderID, w.ClientRequestID, w.DueDate, w.WorkDate, IsNull(w.Inactive,0) as Inactive, w.QestStatusFlags&1 as QestComplete, 
                      s.SampleID, s.DateSampled, w.ProjectCode + ' - ' + w.ProjectName as ProjectCodeName
FROM         WorkOrders w LEFT JOIN
                          ((SELECT     QestUniqueParentID, QestParentID, SampleID, DateSampled 
                              FROM         SampleRegister)
                      UNION ALL
                      (SELECT     QestUniqueParentID, QestParentID, SampleID, DateCast
                       FROM         DocumentConcreteDestructive)) s ON w.QestUniqueID = s.QestUniqueParentID AND w.QestID = s.QestParentID

GO

update DataFilters set SQL = 'SELECT qest_Filter_DefaultWithSamples.DateSampled, qest_Filter_DefaultWithSamples.ProjectCodeName, qest_Filter_DefaultWithSamples.QestID, qest_Filter_DefaultWithSamples.SampleID, qest_Filter_DefaultWithSamples.WorkOrderID FROM qest_Filter_DefaultWithSamples WHERE qest_Filter_DefaultWithSamples.ProjectOwnerCode = {''Project Owner''(Code:20006)} AND qest_Filter_DefaultWithSamples.TechnicianCode = {''Lab Technician ''(Code:20006|LaboratoryTechnician|HasUser=1)} AND qest_Filter_DefaultWithSamples.ClientCode = {''Client ID''(ClientCode:20001)} AND qest_Filter_DefaultWithSamples.ProjectCode = {''Project ID''(ProjectCode:20002|ClientCode)} AND qest_Filter_DefaultWithSamples.WorkOrderID = {''WorkOrder ID''} AND qest_Filter_DefaultWithSamples.ClientRequestID = {''Client Req No''} AND qest_Filter_DefaultWithSamples.DueDate Between {#Due Date#} AND qest_Filter_DefaultWithSamples.WorkDate Between {#Work Date#} AND qest_Filter_DefaultWithSamples.QestComplete = {Complete} AND qest_Filter_DefaultWithSamples.Inactive = 0 AND qest_Filter_DefaultWithSamples.SampleID = {''Sample No''} AND qest_Filter_DefaultWithSamples.DateSampled Between {#Date Sampled#} ORDER BY qest_Filter_DefaultWithSamples.ProjectCodeName, qest_Filter_DefaultWithSamples.WorkOrderID ASC', 
Grouping='qest_Filter_DefaultWithSamples.ProjectCodeName,', 
SearchCriteria='Default|qest_Filter_DefaultWithSamples.QestComplete=No|'
where FilterGroup = 100 and Name = 'Default'