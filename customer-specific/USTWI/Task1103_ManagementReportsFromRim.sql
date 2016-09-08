-- Use reverse lookup to find the parent WO and parent samples for all reports. This view can be used on multiple filters if needed.
CREATE VIEW [dbo].[qestFilterAllReports_RL]
AS
	WITH R AS 
	(
			SELECT 
			reports.*,

			WorkOrderUUID = 
				case 
					when rl.QestParentID = 101 then rl.QestParentUUID
					when rl2.QestParentID = 101 then rl2.QestParentUUID
					when rl3.QestParentID = 101 then rl3.QestParentUUID
					else null
				end,

			WorkOrderQestUniqueID = 
				case 
					when rl.QestParentID = 101 then rl.QestUniqueParentID
					when rl2.QestParentID = 101 then rl2.QestUniqueParentID
					when rl3.QestParentID = 101 then rl3.QestUniqueParentID
					else null
				end,

			SampleUUID = 
				case 
					when rl.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl.QestParentUUID
					when rl2.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl2.QestParentUUID
					when rl3.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl3.QestParentUUID
					else null
				end,

			SampleQestID = 
				case 
					when rl.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl.QestParentID
					when rl2.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl2.QestParentID
					when rl3.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl3.QestParentID
					else null
				end,

			SampleQestUniqueID = 
				case 
					when rl.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl.QestUniqueParentID
					when rl2.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl2.QestUniqueParentID
					when rl3.QestParentID IN (1001,1002,1401,1501,1601,1602,1603,1604,1605,1701,1702,1801) then rl3.QestUniqueParentID
					else null
				end

			FROM qestReverseLookup rl
			INNER JOIN 
			
			(
			SELECT 
			  DE.QestOwnerLabNo
			, DE.ProjectCode
			, DE.ProjectName
			, DE.ClientCode
			, DE.ClientName
			, DE.QestStatusFlags
			, DE.QESTModifiedDate
			, DE.QESTCreatedDate
			, DE.QestCheckedDate
			, DE.SignatoryDate
			, DE.ReportNo
			, DE.QestUUID AS Report_QestUUID
			, DE.QestComplete
			, DE.SignatoryID
			, DE.SignatoryName
			, DE.QestCheckedBy
			, DE.PrintedOrEmailed
			, DE.QestID
			, DE.QestParentID
			, DE.QestUniqueID
			, DE.QestUniqueParentID
			, 1 AS IsExternal
			, DE.PortalUUID

			, Signed = CASE
				WHEN DE.SignatoryID > 0 THEN 1 
				ELSE 0 END 
			, Checked = CASE 
				WHEN DE.QestCheckedBy > 0 THEN 1 
				ELSE 0 END

			FROM DocumentExternal DE

			WHERE	(DE.DocumentClassCode = 'EXTREPORT' OR DE.QESTID = 18210) AND 
					DE.QESTParentID <> 0
			UNION ALL
			SELECT 
			  DC.QestOwnerLabNo
			, DC.ProjectCode
			, DC.ProjectName
			, DC.ClientCode
			, DC.ClientName
			, DC.QestStatusFlags
			, DC.QESTModifiedDate
			, DC.QESTCreatedDate
			, DC.QestCheckedDate
			, DC.SignatoryDate
			, DC.ReportNo
			, DC.QestUUID AS Report_QestUUID
			, DC.QestComplete
			, DC.SignatoryID
			, DC.SignatoryName
			, DC.QestCheckedBy
			, DC.PrintedOrEmailed
			, DC.QestID
			, DC.QestParentID
			, DC.QestUniqueID
			, DC.QestUniqueParentID
			, 0 AS IsExternal
			, DC.PortalUUID

			, Signed = CASE
				WHEN DC.SignatoryID > 0 THEN 1 
				ELSE 0 END 
			, Checked = CASE 
				WHEN DC.QestCheckedBy > 0 THEN 1 
				ELSE 0 END
			
			FROM DocumentCertificates DC
			) reports
			
			ON rl.QestID = reports.QestID AND rl.QestUniqueID = reports.QestUniqueID
			LEFT JOIN qestReverseLookup rl2 ON rl.QestParentID = rl2.QestID AND rl.QestUniqueParentID = rl2.QestUniqueID
			LEFT JOIN qestReverseLookup rl3 ON rl2.QestParentID = rl3.QestID AND rl2.QestUniqueParentID = rl3.QestUniqueID
	)

	SELECT PCB.Name AS CheckedByName,QO.Value AS ReportName, R.* 
	FROM R 
	LEFT JOIN Users UCB ON UCB.QESTUniqueID = R.QestCheckedBy
	LEFT JOIN people PCB ON PCB.QestUniqueID = UCB.PersonID
	LEFT JOIN qestObjects QO ON QO.QestID = R.QestID AND QO.Property = 'Name'
GO


CREATE VIEW [dbo].[qestfilter_DOC_Default]
AS
SELECT        R_1.QestCheckedBy, R_1.QestID, R_1.QestUniqueParentID, R_1.QestUniqueID, R_1.QestParentID, R_1.ReportNo, R_1.SignatoryID, WO.QestOwnerLabNo, 
                         WO.WorkDate, WO.WorkOrderID, WO.ClientCode, WO.ClientName, WO.ProjectCode, WO.ProjectName, WO.QestStatusFlags, 
                         CASE WO.QestStatusFlags & 128 WHEN 128 THEN 1 ELSE 0 END AS TestsComplete, WO.ProjectOwnerCode, WO.ProjectOwnerName, WO.ProjectOwnerNo, 
                         WO.PersonCode, WO.FieldWorkComplete, lp.ProjectTypeCode, WO.TechnicianCode, CASE WHEN ISNULL(R_1.SignatoryID, 0) 
                         = 0 THEN 1 WHEN (cd.QestID IS NOT NULL AND R_1.SignatoryDate < cd.TestDate) AND ISNULL(cd.CompleteFlag, 0) = 1 THEN 1 ELSE 0 END AS toReview, 
                         R_1.Signed, R_1.Checked, R_1.ReportName, WO.PersonName, WO.TechnicianName
FROM            dbo.qestFilterAllReports_RL AS R_1 INNER JOIN
                         dbo.WorkOrders AS WO ON R_1.WorkOrderQestUniqueID = WO.QestUniqueID LEFT OUTER JOIN
                         dbo.ListProject AS lp ON WO.ProjectCode = lp.ProjectCode LEFT OUTER JOIN
                             (SELECT        QestID, QestUniqueID, QestParentID, QestUniqueParentID, MAX(TestDate) AS TestDate, 1 AS CompleteFlag
                               FROM            (SELECT        dcd.QestID, dcd.QestUniqueID, dcd.QestParentID, dcd.QestUniqueParentID, dcds.TestDate, (CASE WHEN (ISNULL(DCDS.QESTComplete, 
                                                                                   0) = 1 AND DCDS.AgeDays <> 999) THEN 1 ELSE 0 END) AS CompleteAndAge, (CASE WHEN (DCDS.Marks IN
                                                                                       (SELECT        MarkCode
                                                                                         FROM            ListMarks
                                                                                         WHERE        Complete = 1)) THEN 1 ELSE 0 END) AS CompleteMarks, (CASE WHEN (dcds.Strength_IP > 0) THEN 1 ELSE 0 END) 
                                                                                   AS CompleteStrength
                                                         FROM            dbo.DocumentConcreteDestructive AS dcd LEFT OUTER JOIN
                                                                                   dbo.DocumentConcreteDestructiveSpecimen AS dcds ON dcd.QestID = dcds.QestParentID AND 
                                                                                   dcd.QestUniqueID = dcds.QestUniqueParentID) AS dcdsflags
                               WHERE        (CompleteAndAge = 1) OR
                                                         (CompleteMarks = 1) OR
                                                         (CompleteStrength = 1)
                               GROUP BY QestID, QestUniqueID, QestParentID, QestUniqueParentID) AS cd ON cd.QestUniqueParentID = WO.QestUniqueID AND 
                         cd.QestParentID = WO.QestID AND R_1.SampleQestID = cd.QestID AND R_1.SampleQestUniqueID = cd.QestUniqueID


GO

CREATE VIEW [dbo].[qestfilter_DOC_Signatory_QA_Review]
AS    
	SELECT
		R_1.QestCheckedBy,
		R_1.QestID, 
		R_1.QestUniqueParentID, 
		R_1.QestUniqueID, 
		R_1.QestParentID, 
		R_1.ReportNo, 
		R_1.SignatoryID, 
		WO.QestOwnerLabNo, 
		WO.WorkDate, 
		WO.WorkOrderID, 
		WO.ClientCode, 
		WO.ClientName, 
		WO.ProjectCode, 
		WO.ProjectName, 
		WO.QestStatusFlags, 
		CASE WO.QestStatusFlags & 128 
			WHEN 128 THEN 1 
			ELSE 0 END AS TestsComplete, 
		WO.ProjectOwnerCode, 
		WO.ProjectOwnerName, 
        WO.ProjectOwnerNo, 
		WO.PersonCode, 
		WO.FieldWorkComplete, 
		lp.ProjectTypeCode, 
		WO.TechnicianCode,
		toReview = CASE 
			WHEN ISNULL(R_1.SignatoryID,0) = 0 THEN 1 
			WHEN (DCDS.QestUniqueID IS NOT NULL AND R_1.SignatoryDate < DCDS.TestDate) AND -- For concrete only
				(
					(ISNULL(DCDS.QESTComplete,0) = 1 AND DCDS.AgeDays <> 999) OR
					(DCDS.Marks IN (SELECT MarkCode FROM ListMarks WHERE Complete = 1)) OR
					DCDS.Strength_IP > 0
				)
			THEN 1
			ELSE 0
		END,
		
		R_1.Signed,
		R_1.Checked,
		R_1.ReportName

	FROM qestFilterAllReports_RL AS R_1 
	INNER JOIN dbo.WorkOrders AS WO ON R_1.WorkOrderQestUniqueID = WO.QestUniqueID
	LEFT JOIN dbo.ListProject AS lp ON WO.ProjectCode = lp.ProjectCode
	LEFT JOIN dbo.DocumentConcreteDestructive DCD ON DCD.QestUniqueParentID = WO.QestUniqueID AND DCD.QestParentID = WO.QestID AND R_1.SampleQestID = DCD.QestID
	LEFT JOIN dbo.DocumentConcreteDestructiveSpecimen DCDS ON DCD.QESTUniqueID = DCDS.QESTUniqueParentID AND DCD.QestID = DCDS.QestParentID


GO

CREATE VIEW [dbo].[qestfilter_DOC_Reports_WorkComplete]
AS
SELECT        R_1.QestCheckedBy, R_1.QestID, R_1.QestUniqueParentID, R_1.QestUniqueID, R_1.QestParentID, R_1.ReportNo, R_1.SignatoryID, R_1.QestStatusFlags, 
                         CASE R_1.QestStatusFlags & 64 WHEN 64 THEN 1 ELSE 0 END AS TestReportReady, CASE R_1.QestStatusFlags & 128 WHEN 128 THEN 1 ELSE 0 END AS TestsComplete, WO.QestOwnerLabNo, WO.WorkDate, 
                         WO.WorkOrderID, WO.ClientCode, WO.ClientName, WO.ProjectCode, WO.ProjectName, WO.ProjectOwnerCode, WO.ProjectOwnerName, WO.ProjectOwnerNo, WO.PersonCode, WO.FieldWorkComplete, 
                         lp.ProjectTypeCode, WO.TechnicianCode, CASE WHEN ISNULL(R_1.SignatoryID, 0) = 0 THEN 1 WHEN (cd.QestID IS NOT NULL AND R_1.SignatoryDate < cd.TestDate) AND ISNULL(cd.CompleteFlag, 0) 
                         = 1 THEN 1 ELSE 0 END AS toReview, R_1.Signed, R_1.Checked, R_1.ReportName
FROM            dbo.qestFilterAllReports_RL AS R_1 INNER JOIN
                         dbo.WorkOrders AS WO ON R_1.WorkOrderQestUniqueID = WO.QestUniqueID LEFT OUTER JOIN
                         dbo.ListProject AS lp ON WO.ProjectCode = lp.ProjectCode LEFT OUTER JOIN
                             (SELECT        QestID, QestUniqueID, QestParentID, QestUniqueParentID, MAX(TestDate) AS TestDate, 1 AS CompleteFlag
                               FROM            (SELECT        dcd.QestID, dcd.QestUniqueID, dcd.QestParentID, dcd.QestUniqueParentID, dcds.TestDate, (CASE WHEN (ISNULL(DCDS.QESTComplete, 0) = 1 AND DCDS.AgeDays <> 999) 
                                                                                   THEN 1 ELSE 0 END) AS CompleteAndAge, (CASE WHEN (DCDS.Marks IN
                                                                                       (SELECT        MarkCode
                                                                                         FROM            ListMarks
                                                                                         WHERE        Complete = 1)) THEN 1 ELSE 0 END) AS CompleteMarks, (CASE WHEN (dcds.Strength_IP > 0 OR
                                                                                   dcds.netarea > 0) THEN 1 ELSE 0 END) AS CompleteStrength
                                                         FROM            dbo.DocumentConcreteDestructive AS dcd LEFT OUTER JOIN
                                                                                   dbo.DocumentConcreteDestructiveSpecimen AS dcds ON dcd.QestID = dcds.QestParentID AND dcd.QestUniqueID = dcds.QestUniqueParentID) AS dcdsflags
                               WHERE        (CompleteAndAge = 1) OR
                                                         (CompleteMarks = 1) OR
                                                         (CompleteStrength = 1)
                               GROUP BY QestID, QestUniqueID, QestParentID, QestUniqueParentID) AS cd ON cd.QestUniqueParentID = WO.QestUniqueID AND cd.QestParentID = WO.QestID AND R_1.SampleQestID = cd.QestID AND 
                         R_1.SampleQestUniqueID = cd.QestUniqueID

GO


CREATE VIEW [dbo].[qestfilter_WO_Default]
AS
SELECT        dbo.WorkOrders.QestID, dbo.WorkOrders.QestUniqueID, dbo.WorkOrders.QestParentID, dbo.WorkOrders.QestUniqueParentID, dbo.WorkOrders.WorkOrderID, dbo.WorkOrders.ProjectCode, 
                         dbo.WorkOrders.ProjectName, dbo.WorkOrders.ClientCode, dbo.WorkOrders.ClientName, dbo.WorkOrders.TechnicianCode, dbo.WorkOrders.ProjectOwnerCode, dbo.WorkOrders.DueDate, 
                         dbo.WorkOrders.WorkDate, dbo.WorkOrders.QestOwnerLabNo, dbo.WorkOrders.FieldWorkComplete, dbo.WorkOrders.PersonCode, dbo.WorkOrders.ProjectOwnerName, AllReports.ReportName, 
                         dbo.ListProject.ProjectTypeCode, AllReports.Signed, AllReports.Checked, dbo.WorkOrders.ProjectOwnerNo
FROM            dbo.WorkOrders LEFT OUTER JOIN
                         dbo.ListProject ON dbo.WorkOrders.ProjectCode = dbo.ListProject.ProjectCode AND (dbo.WorkOrders.QestOwnerLabNo = dbo.ListProject.QestOwnerLabNo OR
                         dbo.ListProject.QestOwnerLabNo = 0) LEFT OUTER JOIN
                         dbo.qestFilterAllReports_RL AS AllReports ON dbo.WorkOrders.QestUniqueID = AllReports.WorkOrderQestUniqueID
WHERE        (dbo.WorkOrders.QestID = 101) AND (ISNULL(dbo.WorkOrders.Inactive, 0) = 0)

GO

CREATE VIEW [dbo].[qestfilter_WO_Signatory_QA_Review]
AS

    SELECT
		R_1.QestCheckedBy,
		WO.QestUniqueID, 
		WO.QestID, 
		WO.QestParentID, 
		WO.QestUniqueParentID, 
		R_1.ReportNo, 
		R_1.SignatoryID, 
		WO.QestOwnerLabNo, 
		WO.WorkDate, 
		WO.WorkOrderID, 
		WO.ClientCode, 
		WO.ClientName, 
		WO.ProjectCode, 
		WO.ProjectName, 
		WO.QestStatusFlags, 
		CASE WO.QestStatusFlags & 128 
			WHEN 128 THEN 1 
			ELSE 0 
		END AS TestsComplete, 
		WO.ProjectOwnerCode, 
		WO.ProjectOwnerName, 
        WO.ProjectOwnerNo, 
		WO.PersonCode, 
		WO.FieldWorkComplete, 
		lp.ProjectTypeCode, 
		WO.TechnicianCode,
		toReview = CASE 
			WHEN ISNULL(R_1.SignatoryID,0) = 0 THEN 1 
			WHEN (DCDS.QestUniqueID IS NOT NULL AND R_1.SignatoryDate < DCDS.TestDate) AND -- For concrete only
				(
					(ISNULL(DCDS.QESTComplete,0) = 1 AND DCDS.AgeDays <> 999) OR
					(DCDS.Marks IN (SELECT MarkCode FROM ListMarks WHERE Complete = 1)) OR
					DCDS.Strength_IP > 0
				)
			THEN 1
			ELSE 0
		END,
		R_1.Signed,
		R_1.Checked,
		R_1.ReportName
			
			
    FROM qestFilterAllReports_RL AS R_1
	INNER JOIN dbo.WorkOrders AS WO ON R_1.WorkOrderQestUniqueID = WO.QestUniqueID
	LEFT JOIN dbo.ListProject AS lp ON WO.ProjectCode = lp.ProjectCode
	LEFT JOIN dbo.DocumentConcreteDestructive DCD ON DCD.QestUniqueParentID = WO.QestUniqueID AND DCD.QestParentID = WO.QestID AND R_1.SampleQestID = DCD.QestID
	LEFT JOIN dbo.DocumentConcreteDestructiveSpecimen DCDS ON DCD.QESTUniqueID = DCDS.QESTUniqueParentID AND DCD.QestID = DCDS.QestParentID
GO


if object_id('qestfilterFieldDensityResults','v') is not null
	drop view dbo.qestfilterFieldDensityResults;
go

CREATE VIEW [dbo].[qestfilterFieldDensityResults]
AS
SELECT     S.Location, S.DateSampled, S.FieldSampleID, S.LocationDescription, S.ProductCode, S.ProductName, S.SourceCode, S.SourceName, S.ClientCode, S.ClientName, 
                      S.ProjectCode, S.ProjectName, S.SampleID,
					  --S._LotNo, 
					  ISNULL(CAST(S.Elevation AS NVARCHAR(30)), S.RoadworksDepth) AS FDElevation, S.DepthLevel, 
                      FD.AdjustedMoisture, FD.DryDensity, FD.MoistureContent, FD.NuclearGaugeCode, RC.QestSpecification, FD.RelativeCompaction, FD.SoilDescription, FD.WetDensity, 
                      RC.BulkDryDensity, RC.HilfDR_DDR, RC.MDD, RC.MDDSampleID, RC.MoistureContentReported, RC.MoistureVariation, RC.MoistureVariationAbs, RC.OMC, 
                      RC.QestOutOfSpecification, RC.Retest, W.WorkDate, W.PersonCode, W.PersonName, 
					  COALESCE(W.FieldWorkComplete,CAST(0 AS BIT)) FieldWorkComplete,
					  P.Name AS AddedBy, S.QestID, 
                      S.QestOwnerLabNo, O.Value AS FDTestMethod
FROM         dbo.SampleRegister AS S LEFT OUTER JOIN
                      dbo.WorkOrders AS W ON S.QestUniqueParentID = W.QestUniqueID LEFT OUTER JOIN
                      dbo.DocumentAggSoilCompaction AS RC ON S.QestUniqueID = RC.QestUniqueParentID LEFT OUTER JOIN
                      dbo.DocumentAggSoilFieldDensity AS FD ON S.QestUniqueID = FD.QestUniqueParentID LEFT OUTER JOIN
                      dbo.Users AS U ON RC.QestCreatedBy = U.QESTUniqueID LEFT OUTER JOIN
                      dbo.People AS P ON U.PersonID = P.QestUniqueID LEFT OUTER JOIN
                      dbo.qestObjects AS O ON FD.QestID = O.QestID AND O.Property = 'Method'
WHERE     (W.QestID = 101) AND (S.QestID = 1001) AND (RC.QestID = 110201) AND (FD.QestID = 110304 OR
                      FD.QestID = 110243)

go
if object_id('qestFilterGintSP460','v') is not null
	drop view dbo.qestFilterGintSP460;
go

/*WHERE     (NOT (dbo.DocumentCertificates.SignatoryDate IS NULL))*/
CREATE VIEW [dbo].[qestFilterGintSP460]
AS
SELECT     dbo.Laboratory.Name, dbo.SampleRegister.SampleID, dbo.SampleRegister.ProjectCode, dbo.SampleRegister.TechnicianName, 
                      dbo.SampleRegister.RoadworksBoringNo, dbo.SampleRegister.RoadworksDepth, dbo.SampleRegister.Elevation, CONVERT(date, 
                      dbo.DocumentMoistureContent.QestTestedDate) AS MCTestDate, ROUND(dbo.DocumentMoistureContent.MoistureContentS1, 1) AS MoistureContentS1, 
                      CONVERT(Date, dbo.DocumentParticleSizeDistribution.QestTestedDate) AS PSDTestDate, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_75_0, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_75_0, 1) ELSE NULL END AS Sieve_75_0, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_50_0, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_50_0, 1) ELSE NULL END AS Sieve_50_0, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_37_5, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_37_5, 1) ELSE NULL END AS Sieve_37_5, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_25_0, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_25_0, 1) ELSE NULL END AS Sieve_25_0, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_19_0, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_19_0, 1) ELSE NULL END AS Sieve_19_0, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_9_5, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_9_5, 1) ELSE NULL END AS Sieve_9_5, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_4_75, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_4_75, 1) ELSE NULL END AS Sieve_4_75, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_2_0, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_2_0, 1) ELSE NULL END AS Sieve_2_0, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_850, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_850, 1) ELSE NULL END AS Sieve_0_850, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_425, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_425, 1) ELSE NULL END AS Sieve_0_425, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_250, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_250, 1) ELSE NULL END AS Sieve_0_250, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_180, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_180, 1) ELSE NULL END AS Sieve_0_180, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_150, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_150, 1) ELSE NULL END AS Sieve_0_150, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_106, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_106, 1) ELSE NULL END AS Sieve_0_106, 
                      CASE PercentageType WHEN 'Passing (Cumulative)' THEN ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_075, 1) 
                      WHEN 'Retained (Cumulative)' THEN 100 - ROUND(dbo.DocumentParticleSizeDistribution.Sieve_0_075, 1) ELSE NULL END AS Sieve_0_075, 
                      dbo.DocumentParticleSizeDistribution.CoefficientUniformity, dbo.DocumentParticleSizeDistribution.CoefficientCurvature, CONVERT(date, 
                      dbo.DocumentAtterbergLimits.QestTestedDate) AS AtterbergTestDate, ROUND(dbo.DocumentAtterbergLimits.LiquidLimit, 1) AS LiquidLimit, 
                      ROUND(dbo.DocumentAtterbergLimits.PlasticLimit, 1) AS PlasticLimit, dbo.DocumentAtterbergLimits.LiquidLimitText, 
                      dbo.DocumentAtterbergLimits.PlasticLimitText, 
					  --CONVERT(date, dbo.UserDocument140.QestTestedDate) AS CorrTestDate, dbo.UserDocument140.pH, 
                      --dbo.UserDocument141.SoilResistivity, 
					  CONVERT(date, dbo.DocumentMaximumDryDensity.QestTestedDate) AS MDDTestDate, 
                      ROUND(dbo.DocumentMaximumDryDensity.MaximumDryDensity, 1) AS MaximumDryDensity, 
                      ROUND(dbo.DocumentMaximumDryDensity.OptimumMoistureContent, 1) AS OptimumMoistureContent, 
                      ROUND(dbo.DocumentMaximumDryDensity.AdjustedMDD, 1) AS AdjustedMDD, ROUND(dbo.DocumentMaximumDryDensity.AdjustedOMC, 1) 
                      AS AdjustedOMC, 
					  --ROUND(DocumentOC.OrganicContent, 2) AS OrganicContent, CONVERT(date, DocumentOC.QestTestedDate) AS OCTestDate, 
                      dbo.DocumentUSCS.GroupSymbol, dbo.DocumentCertificates.SignatoryDate, dbo.DocumentCertificates.SignatoryName, 
                      dbo.SampleRegister.QestOwnerLabNo
FROM         dbo.SampleRegister LEFT OUTER JOIN
                      dbo.Laboratory ON dbo.Laboratory.LabNo = dbo.SampleRegister.QestOwnerLabNo LEFT OUTER JOIN
                      dbo.DocumentMoistureContent ON dbo.DocumentMoistureContent.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentMoistureContent.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
                      dbo.DocumentAtterbergLimits ON dbo.DocumentAtterbergLimits.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentAtterbergLimits.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
                      dbo.DocumentParticleSizeDistribution ON dbo.DocumentParticleSizeDistribution.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentParticleSizeDistribution.QestUniqueParentID = dbo.SampleRegister.QestUniqueID AND 
                      dbo.DocumentParticleSizeDistribution.QestID <> 110017 AND dbo.DocumentParticleSizeDistribution.QestID <> 110008 LEFT OUTER JOIN
                      dbo.DocumentMaximumDryDensity ON dbo.DocumentMaximumDryDensity.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentMaximumDryDensity.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
                      dbo.DocumentUSCS ON dbo.DocumentUSCS.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentUSCS.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
       --               dbo.UserDocument140 ON dbo.UserDocument140.QestParentID = dbo.SampleRegister.QestID AND 
       --               dbo.UserDocument140.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
       --               dbo.UserDocument141 ON dbo.UserDocument141.QestParentID = dbo.SampleRegister.QestID AND 
       --               dbo.UserDocument141.QestUniqueParentID = dbo.SampleRegister.QestUniqueID 
					  --LEFT OUTER JOIN
                      --    (SELECT     OrganicContent, QestTestedDate, QestParentID, QestUniqueParentID
                      --      FROM          dbo.DocumentMoistureAshOrganic
                      --      UNION ALL
                      --      SELECT     OrganicContentPercentage AS OrganicContent, QestTestedDate, QestParentID, QestUniqueParentID
                      --      FROM         dbo.UserDocument24) AS DocumentOC ON DocumentOC.QestParentID = dbo.SampleRegister.QestID AND 
                      --DocumentOC.QestUniqueParentID = dbo.SampleRegister.QestUniqueID LEFT OUTER JOIN
                      dbo.DocumentCertificates ON dbo.DocumentCertificates.QestParentID = dbo.SampleRegister.QestID AND 
                      dbo.DocumentCertificates.QestUniqueParentID = dbo.SampleRegister.QestUniqueID
WHERE     (NOT (dbo.DocumentCertificates.SignatoryDate IS NULL))


go

BEGIN TRANSACTION;
SET NOCOUNT ON;

-- Stored procedure for populating the ListBinders table
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('[dbo].[tempProc_AddToDataFilters]') IS NOT NULL
	DROP PROCEDURE [dbo].[tempProc_AddToDataFilters];
GO

CREATE PROCEDURE [dbo].[tempProc_AddToDataFilters]
	@DefaultView nvarchar(50),
	@FilterGroup int,
	@Grouping nvarchar(max),
	@GroupSQL nvarchar(max),
	@HideObjectNodes bit,
	@InternalName nvarchar(50),
	@Locked bit,
	@Name nvarchar(50),
	@Properties nvarchar(max),
	@SearchCriteria nvarchar(max),
	@SQL nvarchar(max),
	@SQLEdit bit,
    @Verbose BIT
AS
	DECLARE @NewLine NVARCHAR(2) = CHAR(13)+ CHAR(10);

	-- Validate the new record
	-- Check Product Code
	IF(@Name IS NULL OR LTRIM(@Name) = '')
	BEGIN
		IF @Verbose = 0 RETURN 0;
		RAISERROR('Invalid filter: Null or '''' is not permitted.
		Input Details: Filter Group = ''%i'',Name = ''%s'' %s',11,1,@FilterGroup,@Name,@NewLine);
		RETURN 0;
	END

	-- Check to see if record exists
	IF (SELECT COUNT(*) FROM DataFilters WHERE FilterGroup = @FilterGroup AND Name = @Name AND convert(nvarchar(max),[SQL]) = @SQL) <> 0
	BEGIN 
		IF @Verbose = 0 RETURN 0;
		RAISERROR('Invalid filter, already exists.
		Input Details: Filter Group = ''%i'',Name = ''%s'' %s',11,1,@FilterGroup,@Name,@NewLine);
		RETURN 0;
	END

	-- Insert the record
	INSERT INTO DataFilters (
		DefaultView,
		FilterGroup,
		Grouping,
		GroupSQL,
		HideObjectNodes,
		InternalName,
		Locked,
		Name,
		Properties,
		SearchCriteria,
		SQL,
		SQLEdit

		)
	VALUES (
		@DefaultView,
		@FilterGroup,
		@Grouping,
		@GroupSQL,
		@HideObjectNodes,
		@InternalName,
		@Locked,
		@Name,
		@Properties,
		@SearchCriteria,
		@SQL,
		@SQLEdit

	)
GO

-- Stored procedure for populating the ListBinders table
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('[dbo].[tempProc_AddToReports]') IS NOT NULL
	DROP PROCEDURE [dbo].[tempProc_AddToReports];
GO

CREATE PROCEDURE [dbo].[tempProc_AddToReports]
	@AlternateSpecification bit,
	@AlternateSpecificationName nvarchar(50),
	@Chart bit,
	@ChartSize1 smallint,
	@ChartSize2 smallint,
	@ChartSize3 smallint,
	@ChartSize4 smallint,
	@ChartSize5 smallint,
	@Columns nvarchar(max),
	@CustomReportObject nvarchar(255),
	@DetailFontBold bit,
	@DetailFontItalic bit,
	@DetailFontName nvarchar(50),
	@DetailFontSize real,
	@DifferenceValues bit,
	@DocumentNo nvarchar(50),
	@Fields nvarchar(max),
	@FilterName nvarchar(50),
	@GroupForLastN bit,
	@GroupNewPage bit,
	@HeaderFontBold bit,
	@HeaderFontItalic bit,
	@HeaderFontName nvarchar(50),
	@HeaderFontSize real,
	@IndentLeft real,
	@IndentRight real,
	@LastN nvarchar(50),
	@LastNDateField nvarchar(50),
	@LimitFontBold bit,
	@LimitFontColour int,
	@LimitFontItalic bit,
	@LimitShadingColour int,
	@LineEachRow bit,
	@LineHeight float,
	@Locked bit,
	@Name nvarchar(100),
	@Notes nvarchar(max),
	@Orientation smallint,
	@PageHeight float,
	@PageMarginBottom float,
	@PageMarginLeft float,
	@PageMarginRight float,
	@PageMarginTop float,
	@PageWidth float,
	@Properties nvarchar(max),
	@QestCreatedBy int,
	@QestCreatedDate datetime,
	@QestID int,
	@QestModifiedBy int,
	@QestModifiedDate datetime,
	@QestOwnerLabNo int,
	@ReportGroup nvarchar(50),
	@ShowLimits bit,
	@StatsLine bit,
	@StatsOnly bit,
	@SubTitle nvarchar(max),
	@SubTitleFontBold bit,
	@SubTitleFontItalic bit,
	@SubTitleFontName nvarchar(50),
	@SubTitleFontSize real,
	@SuppressSearchCriteria bit,
	@Title nvarchar(255),
	@TitleFontBold bit,
	@TitleFontItalic bit,
	@TitleFontName nvarchar(50),
	@TitleFontSize real,
    @Verbose BIT
AS
	DECLARE @NewLine NVARCHAR(2) = CHAR(13)+ CHAR(10);

	-- Make sure QestID is valid
	IF(SELECT COUNT(*) FROM qestObjects WHERE QestID = @QestID AND Property = 'TableName' AND Value ='Reports') = 0
	BEGIN
		IF @Verbose = 0 RETURN 0;
		RAISERROR('Invalid QestID - Table Name combinations: 
		Input Details: QestID = ''%i'', Table Name = Reports %s',11,1,@QestID,@NewLine);
		RETURN 0;
	END
	

	-- Validate the new record
	-- Check Product Code
	IF(@Name IS NULL OR @ReportGroup IS NULL OR LTRIM(@Name) = '' OR LTRIM(@ReportGroup) = '')
	BEGIN
		IF @Verbose = 0 RETURN 0;
		RAISERROR('Invalid Bitumen Type: Null or '''' is not permitted.
		Input Details: QestID = ''%i'',Name = ''%s'', Report Group = ''%s'' %s',11,1,@QestID,@Name,@ReportGroup,@NewLine);
		RETURN 0;
	END

	-- Check to see if record exists
	IF (SELECT COUNT(*) FROM Reports WHERE QestID = @QestID AND Name = @Name AND ReportGroup = @ReportGroup) <> 0
	BEGIN 
		IF @Verbose = 0 RETURN 0;
		RAISERROR('Invalid Report, already used in current lab or the global lab.
		Input Details: QestID = ''%i'',Name = ''%s'', Report Group = ''%s'' %s',11,1,@QestID,@Name,@ReportGroup,@NewLine);
		RETURN 0;
	END

	-- Insert the record
	INSERT INTO Reports (
		AlternateSpecification,
		AlternateSpecificationName,
		Chart,
		ChartSize1,
		ChartSize2,
		ChartSize3,
		ChartSize4,
		ChartSize5,
		Columns,
		CustomReportObject,
		DetailFontBold,
		DetailFontItalic,
		DetailFontName,
		DetailFontSize,
		DifferenceValues,
		DocumentNo,
		Fields,
		FilterName,
		GroupForLastN,
		GroupNewPage,
		HeaderFontBold,
		HeaderFontItalic,
		HeaderFontName,
		HeaderFontSize,
		IndentLeft,
		IndentRight,
		LastN,
		LastNDateField,
		LimitFontBold,
		LimitFontColour,
		LimitFontItalic,
		LimitShadingColour,
		LineEachRow,
		LineHeight,
		Locked,
		Name,
		Notes,
		Orientation,
		PageHeight,
		PageMarginBottom,
		PageMarginLeft,
		PageMarginRight,
		PageMarginTop,
		PageWidth,
		Properties,
		QestCreatedBy,
		QestCreatedDate,
		QestID,
		QestModifiedBy,
		QestModifiedDate,
		QestOwnerLabNo,
		ReportGroup,
		ShowLimits,
		StatsLine,
		StatsOnly,
		SubTitle,
		SubTitleFontBold,
		SubTitleFontItalic,
		SubTitleFontName,
		SubTitleFontSize,
		SuppressSearchCriteria,
		Title,
		TitleFontBold,
		TitleFontItalic,
		TitleFontName,
		TitleFontSize

		)
	VALUES (
		@AlternateSpecification,
		@AlternateSpecificationName,
		@Chart,
		@ChartSize1,
		@ChartSize2,
		@ChartSize3,
		@ChartSize4,
		@ChartSize5,
		Replace(@Columns,'  ',@NewLine),
		@CustomReportObject,
		@DetailFontBold,
		@DetailFontItalic,
		@DetailFontName,
		@DetailFontSize,
		@DifferenceValues,
		@DocumentNo,
		@Fields,
		@FilterName,
		@GroupForLastN,
		@GroupNewPage,
		@HeaderFontBold,
		@HeaderFontItalic,
		@HeaderFontName,
		@HeaderFontSize,
		@IndentLeft,
		@IndentRight,
		@LastN,
		@LastNDateField,
		@LimitFontBold,
		@LimitFontColour,
		@LimitFontItalic,
		@LimitShadingColour,
		@LineEachRow,
		@LineHeight,
		@Locked,
		@Name,
		@Notes,
		@Orientation,
		@PageHeight,
		@PageMarginBottom,
		@PageMarginLeft,
		@PageMarginRight,
		@PageMarginTop,
		@PageWidth,
		@Properties,
		@QestCreatedBy,
		@QestCreatedDate,
		@QestID,
		@QestModifiedBy,
		@QestModifiedDate,
		@QestOwnerLabNo,
		@ReportGroup,
		@ShowLimits,
		@StatsLine,
		@StatsOnly,
		@SubTitle,
		@SubTitleFontBold,
		@SubTitleFontItalic,
		@SubTitleFontName,
		@SubTitleFontSize,
		@SuppressSearchCriteria,
		@Title,
		@TitleFontBold,
		@TitleFontItalic,
		@TitleFontName,
		@TitleFontSize

	)
GO


DECLARE @Verbose BIT =1;

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- temp table for records that will be inserted into the DataFilters table
DECLARE @DataFilters TABLE(
	DefaultView nvarchar(50),
	FilterGroup int,
	Grouping nvarchar(max),
	GroupSQL nvarchar(max),
	HideObjectNodes bit,
	InternalName nvarchar(50),
	Locked bit,
	Name nvarchar(50),
	Properties nvarchar(max),
	SearchCriteria nvarchar(max),
	SQL nvarchar(max),
	SQLEdit bit

)

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- temp table for records that will be inserted into the Reports table
DECLARE @Reports TABLE(
	AlternateSpecification bit,
	AlternateSpecificationName nvarchar(50),
	Chart bit,
	ChartSize1 smallint,
	ChartSize2 smallint,
	ChartSize3 smallint,
	ChartSize4 smallint,
	ChartSize5 smallint,
	Columns nvarchar(max),
	CustomReportObject nvarchar(255),
	DetailFontBold bit,
	DetailFontItalic bit,
	DetailFontName nvarchar(50),
	DetailFontSize real,
	DifferenceValues bit,
	DocumentNo nvarchar(50),
	Fields nvarchar(max),
	FilterName nvarchar(50),
	GroupForLastN bit,
	GroupNewPage bit,
	HeaderFontBold bit,
	HeaderFontItalic bit,
	HeaderFontName nvarchar(50),
	HeaderFontSize real,
	IndentLeft real,
	IndentRight real,
	LastN nvarchar(50),
	LastNDateField nvarchar(50),
	LimitFontBold bit,
	LimitFontColour int,
	LimitFontItalic bit,
	LimitShadingColour int,
	LineEachRow bit,
	LineHeight float,
	Locked bit,
	Name nvarchar(100),
	Notes nvarchar(max),
	Orientation smallint,
	PageHeight float,
	PageMarginBottom float,
	PageMarginLeft float,
	PageMarginRight float,
	PageMarginTop float,
	PageWidth float,
	Properties nvarchar(max),
	QestCreatedBy int,
	QestCreatedDate datetime,
	QestID int,
	QestModifiedBy int,
	QestModifiedDate datetime,
	QestOwnerLabNo int,
	ReportGroup nvarchar(50),
	ShowLimits bit,
	StatsLine bit,
	StatsOnly bit,
	SubTitle nvarchar(max),
	SubTitleFontBold bit,
	SubTitleFontItalic bit,
	SubTitleFontName nvarchar(50),
	SubTitleFontSize real,
	SuppressSearchCriteria bit,
	Title nvarchar(255),
	TitleFontBold bit,
	TitleFontItalic bit,
	TitleFontName nvarchar(50),
	TitleFontSize real

)

-- Reports and filters go here
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=sampleid
Alignment=2
Divider=1
Width=3.92615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Work Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=workdate
Alignment=2
Divider=1
Width=1.67538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Specification
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=qestspecification
Alignment=2
Divider=1
Width=3.36
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=% Compaction
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=True
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=hilfdr_ddr
Alignment=2
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=Moisture Variation
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=moisturevariation
Alignment=2
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=location
Alignment=2
Divider=1
Width=6.46307692307692
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=Location Description
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=locationdescription
Alignment=2
Divider=1
Width=6.94769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
', null, 0, 0, 'Arial', 8.25, 0, 'DEN01 -', 'qestid,sampleid,workdate,location,locationdescription,qestspecification,hilfdr_ddr,moisturevariation,', 'Failing Field Density Test Results', 0, 0, 0, 0, 'Arial', 8.25, 0, 0, '', '', 0, 255, 0, -1, 0, 210, 0, 'Failing Field Density Test Results', '', 2, 21.59, 1, 1, 1, 1, 27.94, '', 1, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 1, 0, 0, 'Lists all failing field density tests that do not have a passing retest. Samples that have failed and been retested with a passing test result are not displayed on this report.', 0, 0, 'Arial', 8.25, 0, 'Failing Field Density Test Results', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Specimen ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FieldSheetAndID
Alignment=2
AlignmentData=0
Divider=1
Width=3.39692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Type
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Type
Alignment=0
AlignmentData=0
Divider=1
Width=1.91692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=LocationDescription
Alignment=2
AlignmentData=0
Divider=1
Width=4.09846153846154
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Date Cast
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=DateCast
Alignment=0
AlignmentData=0
Divider=1
Width=2.18153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=Supplier
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SupplierName
Alignment=0
AlignmentData=0
Divider=0
Width=2.66769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Product
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProductName
Alignment=0
AlignmentData=0
Divider=1
Width=2.57538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=Air \n(%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MeasuredAir
Alignment=0
AlignmentData=0
Divider=0
Width=1.21538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
START[COLUMN8]
Header=Slump (in)
DataFormat=0.00
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MeasuredSlump
Alignment=0
AlignmentData=0
Divider=0
Width=1.4
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN8]
START[COLUMN9]
Header=Unit Wt.\n( PCY)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MeasuredDensity
Alignment=0
AlignmentData=0
Divider=1
Width=1.46769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN9]
START[COLUMN10]
Header=Age (days)
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AgeDays
Alignment=0
AlignmentData=0
Divider=0
Width=1.09076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN10]
START[COLUMN11]
Header=Test Date
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=TestDate
Alignment=0
AlignmentData=0
Divider=0
Width=2.18153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN11]
START[COLUMN12]
Header=Strength (psi)
DataFormat=0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=True
Statminimum=True
Statmaximum=True
Stataverage=True
StatStandardDeviation=True
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Strength_IP
Alignment=0
AlignmentData=0
Divider=1
Width=1.67538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN12]
', null, 0, 0, 'Arial', 8.25, 0, 'COMP01 -', 'AcceptanceAge,ClientCode,ClientName,COMP100AvgStrength_28,COMP100AvgStrength_7,DateCast,Docket,Fc,FieldSheetNo,LocationDescription,MeasuredAir,MeasuredDensity,MeasuredSlump,ProductCode,ProductName,ProjectCode,ProjectName,QestID,QestUniqueID,SampleID,SourceCode,SourceName,Specimens,SupplierCode,SupplierName,AgeDays,Density,FieldSheetAndID,QestIDDocumentConcreteDestructiveSpecimen,QestUniqueIDDocumentConcreteDestructiveSpecimen,Strength_IP,TestDate,TimeTested,Type,', 'RES - Concrete Compressive Strength - table', 0, 0, 1, 0, 'Arial', 8.25, 0, 0, '', '', 0, -1, 0, -1, 0, 210, 0, 'Compressive Strength', '', 2, 21.59, 1, 1, 1, 1, 27.94, '', 9, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Compressive strength test results falling in the given search criteria.', 0, 0, 'Arial', 8.25, 0, 'Compressive Strength', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, '', 0, null, null, null, null, null, 'START[COLUMN1]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SampleID
Alignment=0
Divider=1
Width=2.73692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Work Date
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WorkDate
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Method
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Method
Alignment=0
Divider=1
Width=2.72461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=MDD (lb/ft^3)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MaximumDryDensity
Alignment=0
Divider=0
Width=1.14461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=OMC (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=OptimumMoistureContent
Alignment=0
Divider=1
Width=0.936923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Adjusted MDD (lb/ft^3)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AdjustedMDD
Alignment=0
Divider=0
Width=1.44461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=Adjusted OMC (lb/ft^3)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AdjustedOMC
Alignment=0
Divider=1
Width=1.35230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
START[COLUMN8]
Header=LL
DataFormat=0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=liquidlimit
Alignment=0
Divider=1
Width=0.729230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN8]
START[COLUMN9]
Header=PL
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PL
Alignment=0
Divider=1
Width=0.66
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN9]
START[COLUMN10]
Header=PI
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PLI
Alignment=0
Divider=1
Width=0.647692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN10]
START[COLUMN11]
Header=Material
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProductName
Alignment=2
Divider=1
Width=5.30923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN11]
START[COLUMN12]
Header=Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=LocationDescription
Alignment=2
Divider=1
Width=6.44
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN12]
', null, 0, 0, 'Arial', 8.25, 0, 'TR01 -', 'Method,AdjustedMDD,AdjustedOMC,HammerDescription,MaximumDryDensity,MethodUsed,OptimumMoistureContent,QestIDDocumentMaximumDryDensity,Visual,QestIDWorkOrders,TechnicianName,WorkDate,ProductName,ProjectCode,ProjectName,QestID,SampleID,SourceCode,SupplierCode,LocationDescription,liquidlimit,PLI,PL,', 'RES - Proctor Results', 0, 0, 0, 0, 'Arial', 8.25, 0, 0, '', '', 0, -1, 0, -1, 0, 210, 0, 'Proctor Results', '', 2, 21.59, 1, 1, 1, 1, 27.94, '', 30, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Returns all proctor results for a given project. If an Atterberg is on the same sample as the proctor, then the Atterberg results are also reported.', 0, 0, 'Arial', 8.25, 0, 'Proctor Results', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=DateSampled
Alignment=0
AlignmentData=0
Divider=1
Width=1.21384615384615
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SampleID
Alignment=0
AlignmentData=0
Divider=1
Width=2.34461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Field Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FieldSampleID
Alignment=0
AlignmentData=0
Divider=1
Width=2.39076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Field Technician
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PersonName
Alignment=0
AlignmentData=0
Divider=1
Width=2.89538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=General Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Location
Alignment=0
AlignmentData=0
Divider=1
Width=3.54
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=LocationDescription
Alignment=0
AlignmentData=0
Divider=1
Width=3.40153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=Compacted To
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=DepthLevel
Alignment=0
AlignmentData=0
Divider=1
Width=2.11384615384615
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
START[COLUMN8]
Header=Elev
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FDElevation
Alignment=0
AlignmentData=0
Divider=1
Width=1.10923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN8]
START[COLUMN9]
Header=Proctor ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MDDSampleID
Alignment=0
AlignmentData=0
Divider=1
Width=1.76769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN9]
START[COLUMN10]
Header=Source
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SourceName
Alignment=0
AlignmentData=0
Divider=1
Width=1.63230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN10]
START[COLUMN11]
Header=Material
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProductName
Alignment=0
AlignmentData=0
Divider=1
Width=4.24
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN11]
START[COLUMN12]
Header=Method
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FDTestMethod
Alignment=0
AlignmentData=0
Divider=1
Width=1.15538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN12]
START[COLUMN13]
Header=MDD
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MDD
Alignment=0
AlignmentData=0
Divider=1
Width=0.96
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN13]
START[COLUMN14]
Header=OMC (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=OMC
Alignment=0
AlignmentData=0
Divider=1
Width=0.821538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN14]
START[COLUMN15]
Header=Wet Dens. (pcf)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WetDensity
Alignment=0
AlignmentData=0
Divider=1
Width=1.00153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN15]
START[COLUMN16]
Header=Dry Dens. (pcf)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=BulkDryDensity
Alignment=0
AlignmentData=0
Divider=1
Width=0.844615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN16]
START[COLUMN17]
Header=MC (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MoistureContentReported
Alignment=0
AlignmentData=0
Divider=1
Width=0.683076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN17]
START[COLUMN18]
Header=% Comp
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=True
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=HilfDR_DDR
Alignment=0
AlignmentData=0
Divider=1
Width=0.936923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN18]
START[COLUMN19]
Header=Moist. Var.
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MoistureVariation
Alignment=0
AlignmentData=0
Divider=1
Width=0.993846153846154
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN19]
START[COLUMN20]
Header=Spec.
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=QestSpecification
Alignment=0
AlignmentData=0
Divider=1
Width=2.13230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN20]
START[COLUMN21]
Header=Out of Spec.
DataFormat=\N\o;\Y\e\s
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=QestOutOfSpecification
Alignment=0
AlignmentData=0
Divider=1
Width=1.07538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=1,0,0,
HighlightMarginalColour=255
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN21]
START[COLUMN22]
Header=Retest
DataFormat=\N\o;\Y\e\s
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Retest
Alignment=0
AlignmentData=0
Divider=1
Width=1.14461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=1,0,0,
HighlightMarginalColour=65535
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN22]
START[COLUMN23]
Header=Work Complete
DataFormat=\N\o;\Y\e\s
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FieldWorkComplete
Alignment=0
AlignmentData=0
Divider=1
Width=1.39230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=1,0,0,
HighlightMarginalColour=65535
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN23]
', null, 0, 0, 'Arial', 6.75, 0, 'DEN02 -', 'AddedBy,AdjustedMoisture,BulkDryDensity,ClientCode,ClientName,DateSampled,DepthLevel,DryDensity,FDElevation,FDTestMethod,FieldSampleID,FieldWorkComplete,HilfDR_DDR,Location,LocationDescription,MDD,MDDSampleID,MoistureContent,MoistureContentReported,MoistureVariation,MoistureVariationAbs,NuclearGaugeCode,OMC,PersonCode,PersonName,ProductCode,ProductName,ProjectCode,ProjectName,QestID,QestOutOfSpecification,QestOwnerLabNo,QestSpecification,RelativeCompaction,Retest,SampleID,SoilDescription,SourceName,WetDensity,WorkDate,', 'Field Density Summary by Project', 0, 0, 1, 0, 'Arial', 8.25, 0, 0, '', '', 1, -1, 0, 255, 1, 180, 0, 'Field Density Summary Report by Project', '', 2, 27.94, 1, 0.1, 0.1, 1, 43.18, '', 103, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Shows a summary of all field density tests completed on a project.', 0, 0, 'Arial', 8.25, 0, 'Field Density Summary Report by Project', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Work Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WorkDate
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SampleID
Alignment=0
Divider=1
Width=2.80615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Product Name
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProductName
Alignment=2
Divider=1
Width=4.00615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Marshall\npcf
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WeightPerCubicFoot
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=Rice
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MaximumDensity_IP
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
', null, 0, 0, 'Arial', 8.25, 0, 'AC03 -', 'ProjectName,QestIDWorkOrders,WorkDate,WorkOrderID,ClientCode,DateSampled,ProductCode,ProductName,ProjectCode,QestID,SampleID,SourceCode,SupplierCode,MaximumDensity_IP,QestIDDocumentAsphaltMaximumDensity,QestIDDocumentAsphaltBulkSpecificGravity,WeightPerCubicFoot,', 'Max Density Results by Project', 0, 0, 0, 0, 'Arial', 8.25, 0, 0, '', '', 0, -1, 0, -1, 0, 210, 0, 'Asphalt Max Density Results', '', 1, 27.94, 1, 1, 1, 1, 21.59, '', 1, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Returns a summary by project of reference densities - Rice ASTM D 2041, Marshall ASTM D 2726', 0, 0, 'Arial', 8.25, 0, 'Asphalt Max Density Results', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 1, 100, 0, 0, 0, 0, 'START[COLUMN1]
FieldName=DateCast
DataFormat=DateCast
PointFormat=dd/mm/yyyy
ChartSequential=-1
SupressRepeatedXAxisLabels=0
ChartAxisLabel=Date Cast
ChartRawNumber=1
ChartRunningAverageNumber=
ChartExponential=0
PlotAgainstFieldNames=False
ChartNo=0
ShowGrid=0
NoLegend=0
SuppressSearchCriteria=0
ScaleLogarithmic=0
Reversed=0
NoZeroValues=0
SharedXAxis=0
END[COLUMN1]
START[COLUMN2]
FieldName=COMP100AvgStrength_28
Preview=False
ChartNo=2
ChartAxisLabel=
ShowGrid=0
Header=
ChartRaw=0
ChartRawNumber=1
ChartRunningAverage=1
ChartRunningAverageNumber=3
ChartLineAverage=0
ChartLineControl=0
ChartLineUser=0
ChartLineUserMinimum=0
ChartLineUserMaximum=0
ChartSpecLimit=0
ChartPolynomial=1
ChartCusum=0
ChartCusumNormal=0
ChartControlHighlight=0
ChartCpk=0
ChartSpecLimitOffset=0
ChartRange=0
ChartExponential=0
END[COLUMN2]
START[COLUMN3]
FieldName=COMP100AvgStrength_28
Preview=False
ChartNo=1
ChartAxisLabel=Strength (psi)
ShowGrid=0
Header=Avg 28
ChartRaw=1
ChartRawNumber=1
ChartRunningAverage=1
ChartRunningAverageNumber=3
ChartLineAverage=0
ChartLineControl=1
ChartLineUser=0
ChartLineUserMinimum=0
ChartLineUserMaximum=0
ChartSpecLimit=0
ChartPolynomial=0
ChartCusum=0
ChartCusumNormal=0
ChartControlHighlight=0
ChartCpk=0
ChartSpecLimitOffset=0
ChartRange=0
ChartExponential=0
END[COLUMN3]
START[COLUMN4]
FieldName=COMP100AvgStrength_7
Preview=False
ChartNo=1
ChartAxisLabel=Strength (psi)
ShowGrid=0
Header=Avg 7
ChartRaw=1
ChartRawNumber=1
ChartRunningAverage=1
ChartRunningAverageNumber=3
ChartLineAverage=0
ChartLineControl=1
ChartLineUser=0
ChartLineUserMinimum=0
ChartLineUserMaximum=0
ChartSpecLimit=0
ChartPolynomial=0
ChartCusum=0
ChartCusumNormal=0
ChartControlHighlight=0
ChartCpk=0
ChartSpecLimitOffset=0
ChartRange=0
ChartExponential=0
END[COLUMN4]
', null, 0, 0, 'Arial', 8.25, 0, '', 'AcceptanceAge,ClientCode,ClientName,COMP100AvgStrength_28,COMP100AvgStrength_7,DateCast,Docket,Fc,FieldSheetNo,LocationDescription,MeasuredAir,MeasuredDensity,MeasuredSlump,ProductCode,ProductName,ProjectCode,ProjectName,QestID,QestUniqueID,SampleID,SourceCode,SourceName,SupplierCode,SupplierName,', 'RES - Concrete Comp. Strength', 0, 0, 0, 0, 'Arial', 8.25, null, null, null, null, 0, -1, 0, -1, 0, 0, 0, 'Concrete Compressive Strength', null, 2, 21, 1, 1, 1, 1, 29.7, null, 3, CURRENT_TIMESTAMP,90001, 9, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, '', 0, 0, 'Arial', 8.25, 0, 'Concrete Compressive Strength', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Work Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WorkDate
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SampleID
Alignment=0
Divider=1
Width=2.80615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Product Name
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProductName
Alignment=2
Divider=1
Width=4.00615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Max Lab Density
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MaximumLabDensity
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=MLD Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MLDSampleID
Alignment=0
Divider=1
Width=2.52923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Rice or Marshall?
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=RiceOrMarshall
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
', null, 0, 0, 'Arial', 8.25, 0, 'AC02 -', 'IsExternal,IsRice,MaximumLabDensity,MLDMethodDocumentAsphaltFieldDensity,MLDSampleID,QestIDDocumentAsphaltFieldDensity,RiceOrMarshall,SampleIDDocumentAsphaltFieldDensity,ProjectName,QestIDWorkOrders,WorkDate,WorkOrderID,ClientCode,DateSampled,ProductCode,ProductName,ProjectCode,QestID,SampleID,SourceCode,SupplierCode,', 'Bulk Density Results by Project', 0, 0, 0, 0, 'Arial', 8.25, 0, 0, '', '', 0, -1, 0, -1, 0, 210, 0, 'Asphalt Max Densities Used in Field Testing', '', 1, 27.94, 1, 1, 1, 1, 21.59, '', 38, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Returns the reference density (Rice, Marshall, External) used in the asphalt nuclear density test screen for relative compaction calculations.
', 0, 0, 'Arial', 8.25, 0, 'Asphalt Max Densities Used in Field Testing', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Work Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=WorkDate
Alignment=0
Divider=1
Width=1.60615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Project
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=ProjectName
Alignment=0
Divider=1
Width=3.92615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Sample ID
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SampleID
Alignment=0
Divider=1
Width=2.50615384615385
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Field Technician
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PersonName
Alignment=0
Divider=1
Width=1.74461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=General Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Location
Alignment=0
Divider=1
Width=4.36153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=Location
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=LocationDescription
Alignment=0
Divider=1
Width=4.15538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=MLD Method
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MLDMethod
Alignment=0
Divider=1
Width=1.67538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
START[COLUMN8]
Header=MLD (lb/ft³)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MaximumLabDensity
Alignment=0
Divider=1
Width=1.07538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN8]
START[COLUMN9]
Header=In situ Density (lb/ft³)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=BulkDensity
Alignment=0
Divider=1
Width=1.14461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN9]
START[COLUMN10]
Header=Comp %
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=RelativeCompaction
Alignment=0
Divider=1
Width=1.21384615384615
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN10]
START[COLUMN11]
Header=Work Complete
DataFormat=\N\o;\Y\e\s
RunningType=0
PrevValues_MaxSize=3
WrapText=True
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=FieldWorkComplete
Alignment=0
Divider=1
Width=1.57076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN11]
', null, 0, 0, 'Arial', 8.25, 0, 'AC01 -', 'Location,LocationDescription,QestID,SampleID,BulkDensity,MaximumLabDensity,MLDMethod,QestIDDocumentAsphaltFieldDensity,RelativeCompaction,ClientName,PersonName,ProjectCode,ProjectName,FieldWorkComplete,QestIDWorkOrders,WorkDate,WorkOrderID,Name,', 'Asphalt Field Density Results', 0, 0, 1, 0, 'Arial', 9, 0, 0, '', '', 0, -1, 0, -1, 1, 210, 0, 'Asphalt Field Density Results', '', 2, 21.59, 1, 0.5, 0.5, 1, 27.94, '', 2407, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Returns a summary of asphalt field density results.', 0, 0, 'Arial', 8.25, 0, 'Asphalt Field Density Results', 1, 0, 'Arial', 14.25);
INSERT INTO @Reports(AlternateSpecification,AlternateSpecificationName,Chart,ChartSize1,ChartSize2,ChartSize3,ChartSize4,ChartSize5,Columns,CustomReportObject,DetailFontBold,DetailFontItalic,DetailFontName,DetailFontSize,DifferenceValues,DocumentNo,Fields,FilterName,GroupForLastN,GroupNewPage,HeaderFontBold,HeaderFontItalic,HeaderFontName,HeaderFontSize,IndentLeft,IndentRight,LastN,LastNDateField,LimitFontBold,LimitFontColour,LimitFontItalic,LimitShadingColour,LineEachRow,LineHeight,Locked,Name,Notes,Orientation,PageHeight,PageMarginBottom,PageMarginLeft,PageMarginRight,PageMarginTop,PageWidth,Properties,QestCreatedBy,QestCreatedDate,QestID,QestModifiedBy,QestModifiedDate,QestOwnerLabNo,ReportGroup,ShowLimits,StatsLine,StatsOnly,SubTitle,SubTitleFontBold,SubTitleFontItalic,SubTitleFontName,SubTitleFontSize,SuppressSearchCriteria,Title,TitleFontBold,TitleFontItalic,TitleFontName,TitleFontSize) VALUES(0, null, 0, null, null, null, null, null, 'START[COLUMN1]
Header=Lab
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Name
Alignment=0
Divider=1
Width=2.78307692307692
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN1]
START[COLUMN2]
Header=Lab Tech
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=TechnicianName
Alignment=0
Divider=1
Width=1.14461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN2]
START[COLUMN3]
Header=Approved By
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=SignatoryName
Alignment=0
Divider=1
Width=2.82307692307692
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN3]
START[COLUMN4]
Header=Depth (ft)
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=RoadworksDepth
Alignment=0
Divider=1
Width=0.798461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN4]
START[COLUMN5]
Header=Boring No.
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=RoadworksBoringNo
Alignment=0
Divider=1
Width=1.21384615384615
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN5]
START[COLUMN6]
Header=NMC/Density Test Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MCTestDate
Alignment=0
Divider=1
Width=0.747692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN6]
START[COLUMN7]
Header=MC (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MoistureContentS1
Alignment=0
Divider=1
Width=0.706153846153846
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN7]
START[COLUMN8]
Header=Atterberg Test Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AtterbergTestDate
Alignment=0
Divider=1
Width=0.752307692307692
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN8]
START[COLUMN9]
Header=LL
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=LiquidLimitText
Alignment=0
Divider=1
Width=0.778461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN9]
START[COLUMN10]
Header=PL
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PlasticLimitText
Alignment=0
Divider=1
Width=0.870769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN10]
START[COLUMN11]
Header=Sieve Test Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=PSDTestDate
Alignment=0
Divider=1
Width=0.701538461538462
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN11]
START[COLUMN12]
Header=3" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_75_0
Alignment=0
Divider=1
Width=0.663076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN12]
START[COLUMN13]
Header=2" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_50_0
Alignment=0
Divider=1
Width=0.709230769230769
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN13]
START[COLUMN14]
Header=1 1/2" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_37_5
Alignment=0
Divider=1
Width=0.778461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN14]
START[COLUMN15]
Header=1" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_25_0
Alignment=0
Divider=1
Width=0.778461538461538
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN15]
START[COLUMN16]
Header=3/4" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_19_0
Alignment=0
Divider=1
Width=0.663076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN16]
START[COLUMN17]
Header=3/8" (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_9_5
Alignment=0
Divider=1
Width=0.64
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN17]
START[COLUMN18]
Header=#4 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_4_75
Alignment=0
Divider=1
Width=0.636923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN18]
START[COLUMN19]
Header=#10 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_2_0
Alignment=0
Divider=1
Width=0.590769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN19]
START[COLUMN20]
Header=#20 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_850
Alignment=0
Divider=1
Width=0.613846153846154
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN20]
START[COLUMN21]
Header=#40 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_425
Alignment=0
Divider=1
Width=0.752307692307692
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN21]
START[COLUMN22]
Header=#60 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_250
Alignment=0
Divider=1
Width=0.683076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN22]
START[COLUMN23]
Header=#80 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_180
Alignment=0
Divider=1
Width=0.74
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN23]
START[COLUMN24]
Header=#100 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_150
Alignment=0
Divider=1
Width=0.693846153846154
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN24]
START[COLUMN25]
Header=#140 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_106
Alignment=0
Divider=1
Width=0.66
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN25]
START[COLUMN26]
Header=#200 (%)
DataFormat=0.0
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=Sieve_0_075
Alignment=0
Divider=1
Width=0.683076923076923
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN26]
START[COLUMN27]
Header=Cu
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=CoefficientUniformity
Alignment=0
Divider=1
Width=0.66
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN27]
START[COLUMN28]
Header=Cc
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=CoefficientCurvature
Alignment=0
Divider=1
Width=0.66
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN28]
START[COLUMN29]
Header=Proctor Test Date
DataFormat=mm/dd/yy
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MDDTestDate
Alignment=0
Divider=1
Width=1.00923076923077
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=
HighlightMarginalColour=0
HighlightCritical=
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN29]
START[COLUMN30]
Header=MDD
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=MaximumDryDensity
Alignment=0
Divider=1
Width=0.890769230769231
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN30]
START[COLUMN31]
Header=OMC
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=OptimumMoistureContent
Alignment=0
Divider=1
Width=0.955384615384615
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN31]
START[COLUMN32]
Header=MDD Corr
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AdjustedMDD
Alignment=0
Divider=1
Width=0.96
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN32]
START[COLUMN33]
Header=OMC Corr
DataFormat=
RunningType=0
PrevValues_MaxSize=3
WrapText=False
StatNumber=False
Statminimum=False
Statmaximum=False
Stataverage=False
StatStandardDeviation=False
StatSlope=False
StatSum=False
StatVarCoef=False
StatPercentTrue=False
StatPercentFalse=False
FieldName=AdjustedOMC
Alignment=0
Divider=1
Width=0.867692307692308
DefaultFont=True
FontBold=False
FontItalic=False
FontColour=-1
ShadingColour=-1
ShadingColourData=-1
HighlightMarginal=0,0,0,
HighlightMarginalColour=0
HighlightCritical=0,0,0,
HighlightCriticalColour=0
FootnoteMargPass=
FootnoteMargFail=
FootnoteCritPass=
FootnoteCritFail=
END[COLUMN33]
', null, 0, 0, 'Arial', 6.75, 0, 'gINT01 -', 'AdjustedMDD,AdjustedOMC,AtterbergTestDate,CoefficientCurvature,CoefficientUniformity,CorrTestDate,Elevation,GroupSymbol,LiquidLimit,LiquidLimitText,MaximumDryDensity,MCTestDate,MDDTestDate,MoistureContentS1,Name,OCTestDate,OptimumMoistureContent,OrganicContent,pH,PlasticLimit,PlasticLimitText,ProjectCode,PSDTestDate,RoadworksBoringNo,RoadworksDepth,SampleID,Sieve_0_075,Sieve_0_106,Sieve_0_150,Sieve_0_180,Sieve_0_250,Sieve_0_425,Sieve_0_850,Sieve_19_0,Sieve_2_0,Sieve_25_0,Sieve_37_5,Sieve_4_75,Sieve_50_0,Sieve_75_0,Sieve_9_5,SignatoryDate,SignatoryName,SoilResistivity,TechnicianName,', 'Gint Export', 0, 0, 0, 0, 'Arial', 6.75, 0, 0, '', '', 0, -1, 0, -1, 0, 180, 0, 'gINT Export', '', 2, 21.59, 1, 0.1, 0.1, 1, 30, '', 30, CURRENT_TIMESTAMP,90001, 1, CURRENT_TIMESTAMP,0, 'Test Results', 0, 0, 0, 'Export this report as a .csv file for import into gINT', 0, 0, 'Arial', 8.25, 1, 'gINT Export', 1, 0, 'Arial', 14.25);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, '', '', 0, null, null, 'Asphalt Field Density Results', '', NULL, 'SELECT   SampleRegister.Location, SampleRegister.LocationDescription, SampleRegister.QestID, SampleRegister.SampleID, DocumentAsphaltFieldDensity.BulkDensity, DocumentAsphaltFieldDensity.MaximumLabDensity, DocumentAsphaltFieldDensity.MLDMethod, DocumentAsphaltFieldDensity.QestID AS QestIDDocumentAsphaltFieldDensity, DocumentAsphaltFieldDensity.RelativeCompaction, WorkOrders.ClientName, WorkOrders.PersonName, WorkOrders.ProjectCode, WorkOrders.ProjectName, WorkOrders.FieldWorkComplete, WorkOrders.QestID AS QestIDWorkOrders, WorkOrders.WorkDate, WorkOrders.WorkOrderID, People.Name  FROM (SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentAsphaltFieldDensity ON SampleRegister.QestUniqueID = DocumentAsphaltFieldDensity.QestUniqueParentID   LEFT JOIN Users on DocumentAsphaltFieldDensity.QestCreatedBy = Users.QestUniqueID  LEFT JOIN People on Users.PersonID = People.QestUniqueID  WHERE WorkOrders.QestID = 101 AND SampleRegister.QestID = 1701 AND DocumentAsphaltFieldDensity.QestID IN (117018,117062) AND ( WorkOrders.WorkDate Between {#Work Date#} AND WorkOrders.ProjectCode = {''Project''(ProjectCode:20002)}) ORDER BY  WorkOrders.WorkDate ASC, SampleRegister.SampleID ASC', 1);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, 'WorkOrders.ProjectName,', 'SELECT Count(DocumentAsphaltFieldDensity.IsExternal) AS IsExternal_Count, Avg(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_Avg, Sum(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_Sum, Min(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_Min, Max(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_Max, StDev(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_StDevP, Var(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_VarP, Sum(CAST(DocumentAsphaltFieldDensity.IsExternal AS INT)) AS IsExternal_CountTrue, Count(DocumentAsphaltFieldDensity.IsRice) AS IsRice_Count, Avg(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_Avg, Sum(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_Sum, Min(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_Min, Max(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_Max, StDev(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_StDevP, Var(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_VarP, Sum(CAST(DocumentAsphaltFieldDensity.IsRice AS INT)) AS IsRice_CountTrue, Count(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_Count, Avg(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_Avg, Sum(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_Sum, Min(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_Min, Max(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_Max, StDev(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_StDevP, Var(DocumentAsphaltFieldDensity.MaximumLabDensity) AS MaximumLabDensity_VarP, Sum(CAST(CAST(DocumentAsphaltFieldDensity.MaximumLabDensity AS BIT) AS INT)) AS MaximumLabDensity_CountTrue, Count(DocumentAsphaltFieldDensity.MLDMethod) AS MLDMethodDocumentAsphaltFieldDensity_Count, Count(DocumentAsphaltFieldDensity.MLDSampleID) AS MLDSampleID_Count, Count(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_Count, Avg(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_Avg, Sum(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_Sum, Min(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_Min, Max(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_Max, StDev(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_StDevP, Var(DocumentAsphaltFieldDensity.QestID) AS QestIDDocumentAsphaltFieldDensity_VarP, Sum(CAST(CAST(DocumentAsphaltFieldDensity.QestID AS BIT) AS INT)) AS QestIDDocumentAsphaltFieldDensity_CountTrue, Count(DocumentAsphaltFieldDensity.RiceOrMarshall) AS RiceOrMarshall_Count, Count(DocumentAsphaltFieldDensity.SampleID) AS SampleIDDocumentAsphaltFieldDensity_Count, WorkOrders.ProjectName, Count(WorkOrders.QestID) AS QestIDWorkOrders_Count, Avg(WorkOrders.QestID) AS QestIDWorkOrders_Avg, Sum(WorkOrders.QestID) AS QestIDWorkOrders_Sum, Min(WorkOrders.QestID) AS QestIDWorkOrders_Min, Max(WorkOrders.QestID) AS QestIDWorkOrders_Max, StDev(WorkOrders.QestID) AS QestIDWorkOrders_StDevP, Var(WorkOrders.QestID) AS QestIDWorkOrders_VarP, Sum(CAST(CAST(WorkOrders.QestID AS BIT) AS INT)) AS QestIDWorkOrders_CountTrue, Count(WorkOrders.WorkDate) AS WorkDate_Count, Count(WorkOrders.WorkOrderID) AS WorkOrderID_Count, Count(SampleRegister.ClientCode) AS ClientCode_Count, Count(SampleRegister.DateSampled) AS DateSampled_Count, Count(SampleRegister.ProductCode) AS ProductCode_Count, Count(SampleRegister.ProductName) AS ProductName_Count, Count(SampleRegister.ProjectCode) AS ProjectCode_Count, Count(SampleRegister.QestID) AS QestID_Count, Avg(SampleRegister.QestID) AS QestID_Avg, Sum(SampleRegister.QestID) AS QestID_Sum, Min(SampleRegister.QestID) AS QestID_Min, Max(SampleRegister.QestID) AS QestID_Max, StDev(SampleRegister.QestID) AS QestID_StDevP, Var(SampleRegister.QestID) AS QestID_VarP, Sum(CAST(CAST(SampleRegister.QestID AS BIT) AS INT)) AS QestID_CountTrue, Count(SampleRegister.SampleID) AS SampleID_Count, Count(SampleRegister.SourceCode) AS SourceCode_Count, Count(SampleRegister.SupplierCode) AS SupplierCode_Count FROM (SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentAsphaltFieldDensity ON SampleRegister.QestUniqueID = DocumentAsphaltFieldDensity.QestUniqueParentID WHERE WorkOrders.QestID = 101 AND SampleRegister.QestID = 1701 AND DocumentAsphaltFieldDensity.QestID = 117062 AND ( WorkOrders.ProjectName Like {''Project''(ProjectCode:20002)} AND SampleRegister.SupplierCode = {''Supplier''(SupplierCode:20028)} AND SampleRegister.SourceCode = {''Plant''(SourceCode:20008)} AND SampleRegister.ProductCode = {''Mix''(ProductCode:20007)} AND WorkOrders.WorkDate Between {#Work Date#}) GROUP BY WorkOrders.ProjectName ORDER BY WorkOrders.ProjectName', 0, null, null, 'Bulk Density Results by Project', '', NULL, 'SELECT  DocumentAsphaltFieldDensity.IsExternal, DocumentAsphaltFieldDensity.IsRice, DocumentAsphaltFieldDensity.MaximumLabDensity, DocumentAsphaltFieldDensity.MLDMethod AS MLDMethodDocumentAsphaltFieldDensity, DocumentAsphaltFieldDensity.MLDSampleID, DocumentAsphaltFieldDensity.QestID AS QestIDDocumentAsphaltFieldDensity, DocumentAsphaltFieldDensity.RiceOrMarshall, DocumentAsphaltFieldDensity.SampleID AS SampleIDDocumentAsphaltFieldDensity, WorkOrders.ProjectName, WorkOrders.QestID AS QestIDWorkOrders, WorkOrders.WorkDate, WorkOrders.WorkOrderID, SampleRegister.ClientCode, SampleRegister.DateSampled, SampleRegister.ProductCode, SampleRegister.ProductName, SampleRegister.ProjectCode, SampleRegister.QestID, SampleRegister.SampleID, SampleRegister.SourceCode, SampleRegister.SupplierCode FROM (SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentAsphaltFieldDensity ON SampleRegister.QestUniqueID = DocumentAsphaltFieldDensity.QestUniqueParentID WHERE WorkOrders.QestID = 101 AND SampleRegister.QestID = 1701 AND DocumentAsphaltFieldDensity.QestID = 117062 AND ( WorkOrders.ProjectName Like {''Project''(ProjectCode:20002)} AND SampleRegister.SupplierCode = {''Supplier''(SupplierCode:20028)} AND SampleRegister.SourceCode = {''Plant''(SourceCode:20008)} AND SampleRegister.ProductCode = {''Mix''(ProductCode:20007)} AND WorkOrders.WorkDate Between {#Work Date#}) ORDER BY  WorkOrders.ProjectName', 0);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, '', '', null, null, null, 'Failing Field Density Test Results', '', NULL, 'SELECT DocumentAggSoilCompaction.qestid, DocumentAggSoilCompaction.sampleid, wo.workdate, sr.location, sr.locationdescription, DocumentAggSoilCompaction.qestspecification, DocumentAggSoilCompaction.hilfdr_ddr, DocumentAggSoilCompaction.moisturevariation FROM DocumentAggSoilCompaction  LEFT JOIN DocumentAggSoilCompaction retest ON DocumentAggSoilCompaction.sampleid = retest.retestsampleid   AND (retest.qestoutofspecification = 0 AND ISNULL(retest.hilfdr_ddr, 0) <> 0)  LEFT JOIN SampleRegister sr ON DocumentAggSoilCompaction.qestuniqueparentid = sr.qestuniqueid AND DocumentAggSoilCompaction.qestparentid = sr.qestid  LEFT JOIN WorkOrders wo ON sr.qestuniqueparentid = wo.qestuniqueid AND sr.qestparentid = wo.qestid  WHERE DocumentAggSoilCompaction.qestoutofspecification = 1 AND retest.qestid IS NULL AND DocumentAggSoilCompaction.retestsampleid IS NULL AND wo.workdate BETWEEN {#Date Tested#}  ORDER BY wo.workdate, DocumentAggSoilCompaction.sampleid', 1);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, 'qestfilterFieldDensityResults.ProjectName,qestfilterFieldDensityResults.DepthLevel,', 'SELECT Count(qestfilterFieldDensityResults.AddedBy) AS AddedBy_Count, Count(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_Count, Avg(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_Avg, Sum(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_Sum, Min(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_Min, Max(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_Max, StDev(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_StDevP, Var(qestfilterFieldDensityResults.AdjustedMoisture) AS AdjustedMoisture_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.AdjustedMoisture AS BIT) AS INT)) AS AdjustedMoisture_CountTrue, Count(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_Count, Avg(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_Avg, Sum(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_Sum, Min(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_Min, Max(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_Max, StDev(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_StDevP, Var(qestfilterFieldDensityResults.BulkDryDensity) AS BulkDryDensity_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.BulkDryDensity AS BIT) AS INT)) AS BulkDryDensity_CountTrue, Count(qestfilterFieldDensityResults.ClientCode) AS ClientCode_Count, Count(qestfilterFieldDensityResults.ClientName) AS ClientName_Count, Count(qestfilterFieldDensityResults.DateSampled) AS DateSampled_Count, qestfilterFieldDensityResults.DepthLevel, Count(qestfilterFieldDensityResults.DryDensity) AS DryDensity_Count, Avg(qestfilterFieldDensityResults.DryDensity) AS DryDensity_Avg, Sum(qestfilterFieldDensityResults.DryDensity) AS DryDensity_Sum, Min(qestfilterFieldDensityResults.DryDensity) AS DryDensity_Min, Max(qestfilterFieldDensityResults.DryDensity) AS DryDensity_Max, StDev(qestfilterFieldDensityResults.DryDensity) AS DryDensity_StDevP, Var(qestfilterFieldDensityResults.DryDensity) AS DryDensity_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.DryDensity AS BIT) AS INT)) AS DryDensity_CountTrue, Count(qestfilterFieldDensityResults.FDElevation) AS FDElevation_Count, Count(qestfilterFieldDensityResults.FDTestMethod) AS FDTestMethod_Count, Count(qestfilterFieldDensityResults.FieldSampleID) AS FieldSampleID_Count, Count(qestfilterFieldDensityResults.FieldWorkComplete) AS FieldWorkComplete_Count, Avg(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_Avg, Sum(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_Sum, Min(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_Min, Max(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_Max, StDev(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_StDevP, Var(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_VarP, Sum(CAST(qestfilterFieldDensityResults.FieldWorkComplete AS INT)) AS FieldWorkComplete_CountTrue, Count(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_Count, Avg(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_Avg, Sum(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_Sum, Min(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_Min, Max(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_Max, StDev(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_StDevP, Var(qestfilterFieldDensityResults.HilfDR_DDR) AS HilfDR_DDR_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.HilfDR_DDR AS BIT) AS INT)) AS HilfDR_DDR_CountTrue, Count(qestfilterFieldDensityResults.Location) AS Location_Count, Count(qestfilterFieldDensityResults.LocationDescription) AS LocationDescription_Count, Count(qestfilterFieldDensityResults.MDD) AS MDD_Count, Avg(qestfilterFieldDensityResults.MDD) AS MDD_Avg, Sum(qestfilterFieldDensityResults.MDD) AS MDD_Sum, Min(qestfilterFieldDensityResults.MDD) AS MDD_Min, Max(qestfilterFieldDensityResults.MDD) AS MDD_Max, StDev(qestfilterFieldDensityResults.MDD) AS MDD_StDevP, Var(qestfilterFieldDensityResults.MDD) AS MDD_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.MDD AS BIT) AS INT)) AS MDD_CountTrue, Count(qestfilterFieldDensityResults.MDDSampleID) AS MDDSampleID_Count, Count(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_Count, Avg(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_Avg, Sum(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_Sum, Min(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_Min, Max(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_Max, StDev(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_StDevP, Var(qestfilterFieldDensityResults.MoistureContent) AS MoistureContent_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.MoistureContent AS BIT) AS INT)) AS MoistureContent_CountTrue, Count(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_Count, Avg(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_Avg, Sum(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_Sum, Min(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_Min, Max(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_Max, StDev(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_StDevP, Var(qestfilterFieldDensityResults.MoistureContentReported) AS MoistureContentReported_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.MoistureContentReported AS BIT) AS INT)) AS MoistureContentReported_CountTrue, Count(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_Count, Avg(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_Avg, Sum(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_Sum, Min(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_Min, Max(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_Max, StDev(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_StDevP, Var(qestfilterFieldDensityResults.MoistureVariation) AS MoistureVariation_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.MoistureVariation AS BIT) AS INT)) AS MoistureVariation_CountTrue, Count(qestfilterFieldDensityResults.MoistureVariationAbs) AS MoistureVariationAbs_Count, Count(qestfilterFieldDensityResults.NuclearGaugeCode) AS NuclearGaugeCode_Count, Count(qestfilterFieldDensityResults.OMC) AS OMC_Count, Avg(qestfilterFieldDensityResults.OMC) AS OMC_Avg, Sum(qestfilterFieldDensityResults.OMC) AS OMC_Sum, Min(qestfilterFieldDensityResults.OMC) AS OMC_Min, Max(qestfilterFieldDensityResults.OMC) AS OMC_Max, StDev(qestfilterFieldDensityResults.OMC) AS OMC_StDevP, Var(qestfilterFieldDensityResults.OMC) AS OMC_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.OMC AS BIT) AS INT)) AS OMC_CountTrue, Count(qestfilterFieldDensityResults.PersonCode) AS PersonCode_Count, Count(qestfilterFieldDensityResults.PersonName) AS PersonName_Count, Count(qestfilterFieldDensityResults.ProductCode) AS ProductCode_Count, Count(qestfilterFieldDensityResults.ProductName) AS ProductName_Count, Count(qestfilterFieldDensityResults.ProjectCode) AS ProjectCode_Count, qestfilterFieldDensityResults.ProjectName, Count(qestfilterFieldDensityResults.QestID) AS QestID_Count, Avg(qestfilterFieldDensityResults.QestID) AS QestID_Avg, Sum(qestfilterFieldDensityResults.QestID) AS QestID_Sum, Min(qestfilterFieldDensityResults.QestID) AS QestID_Min, Max(qestfilterFieldDensityResults.QestID) AS QestID_Max, StDev(qestfilterFieldDensityResults.QestID) AS QestID_StDevP, Var(qestfilterFieldDensityResults.QestID) AS QestID_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.QestID AS BIT) AS INT)) AS QestID_CountTrue, Count(qestfilterFieldDensityResults.QestOutOfSpecification) AS QestOutOfSpecification_Count, Avg(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_Avg, Sum(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_Sum, Min(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_Min, Max(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_Max, StDev(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_StDevP, Var(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_VarP, Sum(CAST(qestfilterFieldDensityResults.QestOutOfSpecification AS INT)) AS QestOutOfSpecification_CountTrue, Count(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_Count, Avg(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_Avg, Sum(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_Sum, Min(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_Min, Max(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_Max, StDev(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_StDevP, Var(qestfilterFieldDensityResults.QestOwnerLabNo) AS QestOwnerLabNo_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.QestOwnerLabNo AS BIT) AS INT)) AS QestOwnerLabNo_CountTrue, Count(qestfilterFieldDensityResults.QestSpecification) AS QestSpecification_Count, Count(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_Count, Avg(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_Avg, Sum(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_Sum, Min(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_Min, Max(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_Max, StDev(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_StDevP, Var(qestfilterFieldDensityResults.RelativeCompaction) AS RelativeCompaction_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.RelativeCompaction AS BIT) AS INT)) AS RelativeCompaction_CountTrue, Count(qestfilterFieldDensityResults.Retest) AS Retest_Count, Avg(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_Avg, Sum(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_Sum, Min(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_Min, Max(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_Max, StDev(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_StDevP, Var(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_VarP, Sum(CAST(qestfilterFieldDensityResults.Retest AS INT)) AS Retest_CountTrue, Count(qestfilterFieldDensityResults.SampleID) AS SampleID_Count, Count(qestfilterFieldDensityResults.SoilDescription) AS SoilDescription_Count, Count(qestfilterFieldDensityResults.SourceName) AS SourceName_Count, Count(qestfilterFieldDensityResults.WetDensity) AS WetDensity_Count, Avg(qestfilterFieldDensityResults.WetDensity) AS WetDensity_Avg, Sum(qestfilterFieldDensityResults.WetDensity) AS WetDensity_Sum, Min(qestfilterFieldDensityResults.WetDensity) AS WetDensity_Min, Max(qestfilterFieldDensityResults.WetDensity) AS WetDensity_Max, StDev(qestfilterFieldDensityResults.WetDensity) AS WetDensity_StDevP, Var(qestfilterFieldDensityResults.WetDensity) AS WetDensity_VarP, Sum(CAST(CAST(qestfilterFieldDensityResults.WetDensity AS BIT) AS INT)) AS WetDensity_CountTrue, Count(qestfilterFieldDensityResults.WorkDate) AS WorkDate_Count FROM qestfilterFieldDensityResults WHERE  qestfilterFieldDensityResults.ClientCode = {''Client Number''(ClientCode:20001)} AND qestfilterFieldDensityResults.ProjectCode = {''Project Number''(ProjectCode:20002|ClientCode)} AND qestfilterFieldDensityResults.ClientName Like {''Client Name''} AND qestfilterFieldDensityResults.ProjectName Like {''Project Name''} AND qestfilterFieldDensityResults.DateSampled Between {#Date Tested#} AND qestfilterFieldDensityResults.Retest = {Retest} AND qestfilterFieldDensityResults.NuclearGaugeCode = {''Nuclear Gauge''} GROUP BY qestfilterFieldDensityResults.ProjectName,qestfilterFieldDensityResults.DepthLevel ORDER BY qestfilterFieldDensityResults.ProjectName,qestfilterFieldDensityResults.DepthLevel', 0, null, null, 'Field Density Summary by Project', '', NULL, 'SELECT        qestfilterFieldDensityResults.AddedBy, qestfilterFieldDensityResults.AdjustedMoisture, qestfilterFieldDensityResults.BulkDryDensity, qestfilterFieldDensityResults.ClientCode, qestfilterFieldDensityResults.ClientName, qestfilterFieldDensityResults.DateSampled, qestfilterFieldDensityResults.DepthLevel, qestfilterFieldDensityResults.DryDensity, qestfilterFieldDensityResults.FDElevation, qestfilterFieldDensityResults.FDTestMethod, qestfilterFieldDensityResults.FieldSampleID, qestfilterFieldDensityResults.FieldWorkComplete, qestfilterFieldDensityResults.HilfDR_DDR, qestfilterFieldDensityResults.Location, qestfilterFieldDensityResults.LocationDescription, qestfilterFieldDensityResults.MDD, qestfilterFieldDensityResults.MDDSampleID, qestfilterFieldDensityResults.MoistureContent, qestfilterFieldDensityResults.MoistureContentReported, qestfilterFieldDensityResults.MoistureVariation, qestfilterFieldDensityResults.MoistureVariationAbs, qestfilterFieldDensityResults.NuclearGaugeCode, qestfilterFieldDensityResults.OMC, qestfilterFieldDensityResults.PersonCode, qestfilterFieldDensityResults.PersonName, qestfilterFieldDensityResults.ProductCode, qestfilterFieldDensityResults.ProductName, qestfilterFieldDensityResults.ProjectCode, qestfilterFieldDensityResults.ProjectName, qestfilterFieldDensityResults.QestID, qestfilterFieldDensityResults.QestOutOfSpecification, qestfilterFieldDensityResults.QestOwnerLabNo, qestfilterFieldDensityResults.QestSpecification, qestfilterFieldDensityResults.RelativeCompaction, qestfilterFieldDensityResults.Retest, qestfilterFieldDensityResults.SampleID, qestfilterFieldDensityResults.SoilDescription, qestfilterFieldDensityResults.SourceName, qestfilterFieldDensityResults.WetDensity, qestfilterFieldDensityResults.WorkDate FROM qestfilterFieldDensityResults WHERE  qestfilterFieldDensityResults.ClientCode = {''Client Number''(ClientCode:20001)} AND qestfilterFieldDensityResults.ProjectCode = {''Project Number''(ProjectCode:20002|ClientCode)} AND qestfilterFieldDensityResults.ClientName Like {''Client Name''} AND qestfilterFieldDensityResults.ProjectName Like {''Project Name''} AND qestfilterFieldDensityResults.DateSampled Between {#Date Tested#} AND qestfilterFieldDensityResults.Retest = {Retest} AND qestfilterFieldDensityResults.NuclearGaugeCode = {''Nuclear Gauge''} ORDER BY  qestfilterFieldDensityResults.ProjectName, qestfilterFieldDensityResults.DepthLevel, qestfilterFieldDensityResults.WorkDate ASC', 0);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, '', 'SELECT Count(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_Count, Avg(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_Avg, Sum(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_Sum, Min(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_Min, Max(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_Max, StDev(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_StDevP, Var(qestFilterGintSP460.AdjustedMDD) AS AdjustedMDD_VarP, Sum(CAST(CAST(qestFilterGintSP460.AdjustedMDD AS BIT) AS INT)) AS AdjustedMDD_CountTrue, Count(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_Count, Avg(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_Avg, Sum(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_Sum, Min(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_Min, Max(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_Max, StDev(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_StDevP, Var(qestFilterGintSP460.AdjustedOMC) AS AdjustedOMC_VarP, Sum(CAST(CAST(qestFilterGintSP460.AdjustedOMC AS BIT) AS INT)) AS AdjustedOMC_CountTrue, Count(qestFilterGintSP460.AtterbergTestDate) AS AtterbergTestDate_Count, Count(qestFilterGintSP460.CoefficientCurvature) AS CoefficientCurvature_Count, Count(qestFilterGintSP460.CoefficientUniformity) AS CoefficientUniformity_Count, Count(qestFilterGintSP460.Elevation) AS Elevation_Count, Avg(qestFilterGintSP460.Elevation) AS Elevation_Avg, Sum(qestFilterGintSP460.Elevation) AS Elevation_Sum, Min(qestFilterGintSP460.Elevation) AS Elevation_Min, Max(qestFilterGintSP460.Elevation) AS Elevation_Max, StDev(qestFilterGintSP460.Elevation) AS Elevation_StDevP, Var(qestFilterGintSP460.Elevation) AS Elevation_VarP, Sum(CAST(CAST(qestFilterGintSP460.Elevation AS BIT) AS INT)) AS Elevation_CountTrue, Count(qestFilterGintSP460.GroupSymbol) AS GroupSymbol_Count, Count(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_Count, Avg(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_Avg, Sum(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_Sum, Min(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_Min, Max(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_Max, StDev(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_StDevP, Var(qestFilterGintSP460.LiquidLimit) AS LiquidLimit_VarP, Sum(CAST(CAST(qestFilterGintSP460.LiquidLimit AS BIT) AS INT)) AS LiquidLimit_CountTrue, Count(qestFilterGintSP460.LiquidLimitText) AS LiquidLimitText_Count, Count(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_Count, Avg(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_Avg, Sum(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_Sum, Min(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_Min, Max(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_Max, StDev(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_StDevP, Var(qestFilterGintSP460.MaximumDryDensity) AS MaximumDryDensity_VarP, Sum(CAST(CAST(qestFilterGintSP460.MaximumDryDensity AS BIT) AS INT)) AS MaximumDryDensity_CountTrue, Count(qestFilterGintSP460.MCTestDate) AS MCTestDate_Count, Count(qestFilterGintSP460.MDDTestDate) AS MDDTestDate_Count, Count(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_Count, Avg(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_Avg, Sum(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_Sum, Min(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_Min, Max(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_Max, StDev(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_StDevP, Var(qestFilterGintSP460.MoistureContentS1) AS MoistureContentS1_VarP, Sum(CAST(CAST(qestFilterGintSP460.MoistureContentS1 AS BIT) AS INT)) AS MoistureContentS1_CountTrue, Count(qestFilterGintSP460.Name) AS Name_Count, Count(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_Count, Avg(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_Avg, Sum(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_Sum, Min(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_Min, Max(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_Max, StDev(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_StDevP, Var(qestFilterGintSP460.OptimumMoistureContent) AS OptimumMoistureContent_VarP, Sum(CAST(CAST(qestFilterGintSP460.OptimumMoistureContent AS BIT) AS INT)) AS OptimumMoistureContent_CountTrue, Count(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_Count, Avg(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_Avg, Sum(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_Sum, Min(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_Min, Max(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_Max, StDev(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_StDevP, Var(qestFilterGintSP460.PlasticLimit) AS PlasticLimit_VarP, Sum(CAST(CAST(qestFilterGintSP460.PlasticLimit AS BIT) AS INT)) AS PlasticLimit_CountTrue, Count(qestFilterGintSP460.PlasticLimitText) AS PlasticLimitText_Count, Count(qestFilterGintSP460.ProjectCode) AS ProjectCode_Count, Count(qestFilterGintSP460.PSDTestDate) AS PSDTestDate_Count, Count(qestFilterGintSP460.RoadworksBoringNo) AS RoadworksBoringNo_Count, Count(qestFilterGintSP460.RoadworksDepth) AS RoadworksDepth_Count, Count(qestFilterGintSP460.SampleID) AS SampleID_Count, Count(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_Count, Avg(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_Avg, Sum(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_Sum, Min(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_Min, Max(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_Max, StDev(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_StDevP, Var(qestFilterGintSP460.Sieve_0_075) AS Sieve_0_075_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_075 AS BIT) AS INT)) AS Sieve_0_075_CountTrue, Count(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_Count, Avg(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_Avg, Sum(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_Sum, Min(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_Min, Max(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_Max, StDev(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_StDevP, Var(qestFilterGintSP460.Sieve_0_106) AS Sieve_0_106_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_106 AS BIT) AS INT)) AS Sieve_0_106_CountTrue, Count(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_Count, Avg(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_Avg, Sum(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_Sum, Min(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_Min, Max(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_Max, StDev(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_StDevP, Var(qestFilterGintSP460.Sieve_0_150) AS Sieve_0_150_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_150 AS BIT) AS INT)) AS Sieve_0_150_CountTrue, Count(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_Count, Avg(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_Avg, Sum(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_Sum, Min(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_Min, Max(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_Max, StDev(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_StDevP, Var(qestFilterGintSP460.Sieve_0_180) AS Sieve_0_180_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_180 AS BIT) AS INT)) AS Sieve_0_180_CountTrue, Count(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_Count, Avg(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_Avg, Sum(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_Sum, Min(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_Min, Max(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_Max, StDev(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_StDevP, Var(qestFilterGintSP460.Sieve_0_250) AS Sieve_0_250_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_250 AS BIT) AS INT)) AS Sieve_0_250_CountTrue, Count(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_Count, Avg(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_Avg, Sum(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_Sum, Min(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_Min, Max(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_Max, StDev(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_StDevP, Var(qestFilterGintSP460.Sieve_0_425) AS Sieve_0_425_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_425 AS BIT) AS INT)) AS Sieve_0_425_CountTrue, Count(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_Count, Avg(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_Avg, Sum(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_Sum, Min(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_Min, Max(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_Max, StDev(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_StDevP, Var(qestFilterGintSP460.Sieve_0_850) AS Sieve_0_850_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_0_850 AS BIT) AS INT)) AS Sieve_0_850_CountTrue, Count(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_Count, Avg(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_Avg, Sum(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_Sum, Min(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_Min, Max(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_Max, StDev(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_StDevP, Var(qestFilterGintSP460.Sieve_19_0) AS Sieve_19_0_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_19_0 AS BIT) AS INT)) AS Sieve_19_0_CountTrue, Count(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_Count, Avg(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_Avg, Sum(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_Sum, Min(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_Min, Max(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_Max, StDev(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_StDevP, Var(qestFilterGintSP460.Sieve_2_0) AS Sieve_2_0_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_2_0 AS BIT) AS INT)) AS Sieve_2_0_CountTrue, Count(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_Count, Avg(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_Avg, Sum(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_Sum, Min(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_Min, Max(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_Max, StDev(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_StDevP, Var(qestFilterGintSP460.Sieve_25_0) AS Sieve_25_0_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_25_0 AS BIT) AS INT)) AS Sieve_25_0_CountTrue, Count(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_Count, Avg(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_Avg, Sum(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_Sum, Min(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_Min, Max(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_Max, StDev(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_StDevP, Var(qestFilterGintSP460.Sieve_37_5) AS Sieve_37_5_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_37_5 AS BIT) AS INT)) AS Sieve_37_5_CountTrue, Count(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_Count, Avg(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_Avg, Sum(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_Sum, Min(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_Min, Max(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_Max, StDev(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_StDevP, Var(qestFilterGintSP460.Sieve_4_75) AS Sieve_4_75_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_4_75 AS BIT) AS INT)) AS Sieve_4_75_CountTrue, Count(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_Count, Avg(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_Avg, Sum(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_Sum, Min(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_Min, Max(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_Max, StDev(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_StDevP, Var(qestFilterGintSP460.Sieve_50_0) AS Sieve_50_0_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_50_0 AS BIT) AS INT)) AS Sieve_50_0_CountTrue, Count(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_Count, Avg(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_Avg, Sum(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_Sum, Min(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_Min, Max(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_Max, StDev(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_StDevP, Var(qestFilterGintSP460.Sieve_75_0) AS Sieve_75_0_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_75_0 AS BIT) AS INT)) AS Sieve_75_0_CountTrue, Count(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_Count, Avg(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_Avg, Sum(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_Sum, Min(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_Min, Max(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_Max, StDev(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_StDevP, Var(qestFilterGintSP460.Sieve_9_5) AS Sieve_9_5_VarP, Sum(CAST(CAST(qestFilterGintSP460.Sieve_9_5 AS BIT) AS INT)) AS Sieve_9_5_CountTrue, Count(qestFilterGintSP460.SignatoryDate) AS SignatoryDate_Count, Count(qestFilterGintSP460.SignatoryName) AS SignatoryName_Count, Count(qestFilterGintSP460.TechnicianName) AS TechnicianName_Count FROM qestFilterGintSP460 WHERE  qestFilterGintSP460.SignatoryDate Between {#Signatory Date#}', 0, null, null, 'Gint Export', '', NULL, 'SELECT  qestFilterGintSP460.AdjustedMDD, qestFilterGintSP460.AdjustedOMC, qestFilterGintSP460.AtterbergTestDate, qestFilterGintSP460.CoefficientCurvature, qestFilterGintSP460.CoefficientUniformity, qestFilterGintSP460.Elevation, qestFilterGintSP460.GroupSymbol, qestFilterGintSP460.LiquidLimit, qestFilterGintSP460.LiquidLimitText, qestFilterGintSP460.MaximumDryDensity, qestFilterGintSP460.MCTestDate, qestFilterGintSP460.MDDTestDate, qestFilterGintSP460.MoistureContentS1, qestFilterGintSP460.Name, qestFilterGintSP460.OptimumMoistureContent, qestFilterGintSP460.PlasticLimit, qestFilterGintSP460.PlasticLimitText, qestFilterGintSP460.ProjectCode, qestFilterGintSP460.PSDTestDate, qestFilterGintSP460.RoadworksBoringNo, qestFilterGintSP460.RoadworksDepth, qestFilterGintSP460.SampleID, qestFilterGintSP460.Sieve_0_075, qestFilterGintSP460.Sieve_0_106, qestFilterGintSP460.Sieve_0_150, qestFilterGintSP460.Sieve_0_180, qestFilterGintSP460.Sieve_0_250, qestFilterGintSP460.Sieve_0_425, qestFilterGintSP460.Sieve_0_850, qestFilterGintSP460.Sieve_19_0, qestFilterGintSP460.Sieve_2_0, qestFilterGintSP460.Sieve_25_0, qestFilterGintSP460.Sieve_37_5, qestFilterGintSP460.Sieve_4_75, qestFilterGintSP460.Sieve_50_0, qestFilterGintSP460.Sieve_75_0, qestFilterGintSP460.Sieve_9_5, qestFilterGintSP460.SignatoryDate, qestFilterGintSP460.SignatoryName, qestFilterGintSP460.TechnicianName FROM qestFilterGintSP460 WHERE  qestFilterGintSP460.SignatoryDate Between {#Signatory Date#}', 0);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, 'WorkOrders.ProjectName,', 'SELECT WorkOrders.ProjectName, Count(WorkOrders.QestID) AS QestIDWorkOrders_Count, Avg(WorkOrders.QestID) AS QestIDWorkOrders_Avg, Sum(WorkOrders.QestID) AS QestIDWorkOrders_Sum, Min(WorkOrders.QestID) AS QestIDWorkOrders_Min, Max(WorkOrders.QestID) AS QestIDWorkOrders_Max, StDev(WorkOrders.QestID) AS QestIDWorkOrders_StDevP, Var(WorkOrders.QestID) AS QestIDWorkOrders_VarP, Sum(CAST(CAST(WorkOrders.QestID AS BIT) AS INT)) AS QestIDWorkOrders_CountTrue, Count(WorkOrders.WorkDate) AS WorkDate_Count, Count(WorkOrders.WorkOrderID) AS WorkOrderID_Count, Count(SampleRegister.ClientCode) AS ClientCode_Count, Count(SampleRegister.DateSampled) AS DateSampled_Count, Count(SampleRegister.ProductCode) AS ProductCode_Count, Count(SampleRegister.ProductName) AS ProductName_Count, Count(SampleRegister.ProjectCode) AS ProjectCode_Count, Count(SampleRegister.QestID) AS QestID_Count, Avg(SampleRegister.QestID) AS QestID_Avg, Sum(SampleRegister.QestID) AS QestID_Sum, Min(SampleRegister.QestID) AS QestID_Min, Max(SampleRegister.QestID) AS QestID_Max, StDev(SampleRegister.QestID) AS QestID_StDevP, Var(SampleRegister.QestID) AS QestID_VarP, Sum(CAST(CAST(SampleRegister.QestID AS BIT) AS INT)) AS QestID_CountTrue, Count(SampleRegister.SampleID) AS SampleID_Count, Count(SampleRegister.SourceCode) AS SourceCode_Count, Count(SampleRegister.SupplierCode) AS SupplierCode_Count, Count(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_Count, Avg(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_Avg, Sum(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_Sum, Min(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_Min, Max(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_Max, StDev(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_StDevP, Var(DocumentAsphaltMaximumDensity.MaximumDensity_IP) AS MaximumDensity_IP_VarP, Sum(CAST(CAST(DocumentAsphaltMaximumDensity.MaximumDensity_IP AS BIT) AS INT)) AS MaximumDensity_IP_CountTrue, Count(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_Count, Avg(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_Avg, Sum(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_Sum, Min(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_Min, Max(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_Max, StDev(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_StDevP, Var(DocumentAsphaltMaximumDensity.QestID) AS QestIDDocumentAsphaltMaximumDensity_VarP, Sum(CAST(CAST(DocumentAsphaltMaximumDensity.QestID AS BIT) AS INT)) AS QestIDDocumentAsphaltMaximumDensity_CountTrue, Count(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_Count, Avg(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_Avg, Sum(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_Sum, Min(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_Min, Max(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_Max, StDev(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_StDevP, Var(DocumentAsphaltBulkSpecificGravity.QestID) AS QestIDDocumentAsphaltBulkSpecificGravity_VarP, Sum(CAST(CAST(DocumentAsphaltBulkSpecificGravity.QestID AS BIT) AS INT)) AS QestIDDocumentAsphaltBulkSpecificGravity_CountTrue, Count(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_Count, Avg(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_Avg, Sum(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_Sum, Min(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_Min, Max(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_Max, StDev(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_StDevP, Var(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot) AS WeightPerCubicFoot_VarP, Sum(CAST(CAST(DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot AS BIT) AS INT)) AS WeightPerCubicFoot_CountTrue FROM ((SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentAsphaltMaximumDensity ON SampleRegister.QestUniqueID = DocumentAsphaltMaximumDensity.QestUniqueParentID) LEFT JOIN DocumentAsphaltBulkSpecificGravity ON SampleRegister.QestUniqueID = DocumentAsphaltBulkSpecificGravity.QestUniqueParentID WHERE WorkOrders.QestID = 101 AND SampleRegister.QestID = 1701 AND (DocumentAsphaltMaximumDensity.QestID = 117064 OR DocumentAsphaltMaximumDensity.QestID = 117059 OR DocumentAsphaltMaximumDensity.QestID = 117054 OR DocumentAsphaltMaximumDensity.QestID = 117050) AND DocumentAsphaltBulkSpecificGravity.QestID = 117126 AND ( WorkOrders.ProjectName Like {''Project''(ProjectCode:20002)} AND SampleRegister.SupplierCode = {''Supplier''(SupplierCode:20028)} AND SampleRegister.SourceCode = {''Plant''(SourceCode:20008)} AND SampleRegister.ProductCode = {''Mix''(ProductCode:20007)} AND WorkOrders.WorkDate Between {#Work Date#}) GROUP BY WorkOrders.ProjectName ORDER BY WorkOrders.ProjectName', 0, null, 0, 'Max Density Results by Project', '', NULL, 'SELECT   WorkOrders.ProjectName, WorkOrders.QestID AS QestIDWorkOrders, WorkOrders.WorkDate, WorkOrders.WorkOrderID, SampleRegister.ClientCode, SampleRegister.DateSampled, SampleRegister.ProductCode, SampleRegister.ProductName, SampleRegister.ProjectCode, SampleRegister.QestID, SampleRegister.SampleID, SampleRegister.SourceCode, SampleRegister.SupplierCode, DocumentAsphaltMaximumDensity.MaximumDensity_IP, DocumentAsphaltMaximumDensity.QestID AS QestIDDocumentAsphaltMaximumDensity, DocumentAsphaltBulkSpecificGravity.QestID AS QestIDDocumentAsphaltBulkSpecificGravity, DocumentAsphaltBulkSpecificGravity.WeightPerCubicFoot FROM ((SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentAsphaltMaximumDensity ON SampleRegister.QestUniqueID = DocumentAsphaltMaximumDensity.QestUniqueParentID) LEFT JOIN DocumentAsphaltBulkSpecificGravity ON SampleRegister.QestUniqueID = DocumentAsphaltBulkSpecificGravity.QestUniqueParentID WHERE WorkOrders.QestID = 101 AND SampleRegister.QestID = 1701 AND (DocumentAsphaltMaximumDensity.QestID = 117064 OR DocumentAsphaltMaximumDensity.QestID = 117059 OR DocumentAsphaltMaximumDensity.QestID = 117054 OR DocumentAsphaltMaximumDensity.QestID = 117050) AND DocumentAsphaltBulkSpecificGravity.QestID = 117126 AND ( WorkOrders.ProjectName Like {''Project''(ProjectCode:20002)} AND SampleRegister.SupplierCode = {''Supplier''(SupplierCode:20028)} AND SampleRegister.SourceCode = {''Plant''(SourceCode:20008)} AND SampleRegister.ProductCode = {''Mix''(ProductCode:20007)} AND WorkOrders.WorkDate Between {#Work Date#}) ORDER BY  WorkOrders.ProjectName', 0);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, 'DocumentConcreteDestructive.ProductName,', 'SELECT Count(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Count, Avg(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Avg, Sum(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Sum, Min(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Min, Max(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Max, StDev(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_StDevP, Var(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.AcceptanceAge AS BIT) AS INT)) AS AcceptanceAge_CountTrue, Count(DocumentConcreteDestructive.ClientCode) AS ClientCode_Count, Count(DocumentConcreteDestructive.ClientName) AS ClientName_Count, Count(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Count, Avg(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Avg, Sum(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Sum, Min(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Min, Max(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Max, StDev(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_StDevP, Var(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.COMP100AvgStrength_28 AS BIT) AS INT)) AS COMP100AvgStrength_28_CountTrue, Count(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Count, Avg(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Avg, Sum(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Sum, Min(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Min, Max(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Max, StDev(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_StDevP, Var(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.COMP100AvgStrength_7 AS BIT) AS INT)) AS COMP100AvgStrength_7_CountTrue, Count(DocumentConcreteDestructive.DateCast) AS DateCast_Count, Count(DocumentConcreteDestructive.Docket) AS Docket_Count, Count(DocumentConcreteDestructive.Fc) AS Fc_Count, Avg(DocumentConcreteDestructive.Fc) AS Fc_Avg, Sum(DocumentConcreteDestructive.Fc) AS Fc_Sum, Min(DocumentConcreteDestructive.Fc) AS Fc_Min, Max(DocumentConcreteDestructive.Fc) AS Fc_Max, StDev(DocumentConcreteDestructive.Fc) AS Fc_StDevP, Var(DocumentConcreteDestructive.Fc) AS Fc_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.Fc AS BIT) AS INT)) AS Fc_CountTrue, Count(DocumentConcreteDestructive.FieldSheetNo) AS FieldSheetNo_Count, Count(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Count, Avg(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Avg, Sum(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Sum, Min(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Min, Max(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Max, StDev(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_StDevP, Var(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredAir AS BIT) AS INT)) AS MeasuredAir_CountTrue, Count(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Count, Avg(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Avg, Sum(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Sum, Min(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Min, Max(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Max, StDev(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_StDevP, Var(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredDensity AS BIT) AS INT)) AS MeasuredDensity_CountTrue, Count(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Count, Avg(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Avg, Sum(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Sum, Min(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Min, Max(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Max, StDev(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_StDevP, Var(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredSlump AS BIT) AS INT)) AS MeasuredSlump_CountTrue, Count(DocumentConcreteDestructive.ProductCode) AS ProductCode_Count, DocumentConcreteDestructive.ProductName, Count(DocumentConcreteDestructive.ProjectCode) AS ProjectCode_Count, Count(DocumentConcreteDestructive.ProjectName) AS ProjectName_Count, Count(DocumentConcreteDestructive.QestID) AS QestID_Count, Avg(DocumentConcreteDestructive.QestID) AS QestID_Avg, Sum(DocumentConcreteDestructive.QestID) AS QestID_Sum, Min(DocumentConcreteDestructive.QestID) AS QestID_Min, Max(DocumentConcreteDestructive.QestID) AS QestID_Max, StDev(DocumentConcreteDestructive.QestID) AS QestID_StDevP, Var(DocumentConcreteDestructive.QestID) AS QestID_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.QestID AS BIT) AS INT)) AS QestID_CountTrue, Count(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Count, Avg(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Avg, Sum(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Sum, Min(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Min, Max(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Max, StDev(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_StDevP, Var(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.QestUniqueID AS BIT) AS INT)) AS QestUniqueID_CountTrue, Count(DocumentConcreteDestructive.SampleID) AS SampleID_Count, Count(DocumentConcreteDestructive.SourceCode) AS SourceCode_Count, Count(DocumentConcreteDestructive.SourceName) AS SourceName_Count, Count(DocumentConcreteDestructive.SupplierCode) AS SupplierCode_Count, Count(DocumentConcreteDestructive.SupplierName) AS SupplierName_Count FROM DocumentConcreteDestructive LEFT JOIN DocumentConcreteDestructiveSpecimen ON DocumentConcreteDestructive.QestUniqueID = DocumentConcreteDestructiveSpecimen.QestUniqueParentID WHERE DocumentConcreteDestructive.QestID = 1602 AND ( DocumentConcreteDestructive.ClientCode = {''Client Code''(ClientCode:20001)} AND DocumentConcreteDestructive.ProjectCode = {''Project Code''(ProjectCode:20002)} AND DocumentConcreteDestructive.DateCast Between {#Date Cast#}) GROUP BY DocumentConcreteDestructive.ProductName ORDER BY DocumentConcreteDestructive.ProductName', null, null, 0, 'RES - Concrete Comp. Strength', '', NULL, 'SELECT  DocumentConcreteDestructive.AcceptanceAge, DocumentConcreteDestructive.ClientCode, DocumentConcreteDestructive.ClientName, DocumentConcreteDestructive.COMP100AvgStrength_28, DocumentConcreteDestructive.COMP100AvgStrength_7, DocumentConcreteDestructive.DateCast, DocumentConcreteDestructive.Docket, DocumentConcreteDestructive.Fc, DocumentConcreteDestructive.FieldSheetNo, DocumentConcreteDestructive.LocationDescription, DocumentConcreteDestructive.MeasuredAir, DocumentConcreteDestructive.MeasuredDensity, DocumentConcreteDestructive.MeasuredSlump, DocumentConcreteDestructive.ProductCode, DocumentConcreteDestructive.ProductName, DocumentConcreteDestructive.ProjectCode, DocumentConcreteDestructive.ProjectName, DocumentConcreteDestructive.QestID, DocumentConcreteDestructive.QestUniqueID, DocumentConcreteDestructive.SampleID, DocumentConcreteDestructive.SourceCode, DocumentConcreteDestructive.SourceName, DocumentConcreteDestructive.SupplierCode, DocumentConcreteDestructive.SupplierName FROM DocumentConcreteDestructive WHERE DocumentConcreteDestructive.QestID = 1602 AND ( DocumentConcreteDestructive.ClientCode = {''Client Code''(ClientCode:20001)} AND DocumentConcreteDestructive.ProjectCode = {''Project Code''(ProjectCode:20002)} AND DocumentConcreteDestructive.DateCast Between {#Date Cast#} AND DocumentConcreteDestructive.ProductCode = {''Product Code''(ProductCode:20021)}) AND DocumentConcreteDestructive.ProductName IS NOT NULL ORDER BY  DocumentConcreteDestructive.ProductName, DocumentConcreteDestructive.DateCast ASC, DocumentConcreteDestructive.QestUniqueID ASC', 1);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('Default', 90000, 'DocumentConcreteDestructive.ClientName,DocumentConcreteDestructive.ProjectName,', 'SELECT Count(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Count, Avg(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Avg, Sum(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Sum, Min(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Min, Max(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_Max, StDev(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_StDevP, Var(DocumentConcreteDestructive.AcceptanceAge) AS AcceptanceAge_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.AcceptanceAge AS BIT) AS INT)) AS AcceptanceAge_CountTrue, Count(DocumentConcreteDestructive.ClientCode) AS ClientCode_Count, DocumentConcreteDestructive.ClientName, Count(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Count, Avg(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Avg, Sum(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Sum, Min(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Min, Max(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_Max, StDev(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_StDevP, Var(DocumentConcreteDestructive.COMP100AvgStrength_28) AS COMP100AvgStrength_28_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.COMP100AvgStrength_28 AS BIT) AS INT)) AS COMP100AvgStrength_28_CountTrue, Count(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Count, Avg(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Avg, Sum(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Sum, Min(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Min, Max(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_Max, StDev(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_StDevP, Var(DocumentConcreteDestructive.COMP100AvgStrength_7) AS COMP100AvgStrength_7_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.COMP100AvgStrength_7 AS BIT) AS INT)) AS COMP100AvgStrength_7_CountTrue, Count(DocumentConcreteDestructive.DateCast) AS DateCast_Count, Count(DocumentConcreteDestructive.Docket) AS Docket_Count, Count(DocumentConcreteDestructive.Fc) AS Fc_Count, Avg(DocumentConcreteDestructive.Fc) AS Fc_Avg, Sum(DocumentConcreteDestructive.Fc) AS Fc_Sum, Min(DocumentConcreteDestructive.Fc) AS Fc_Min, Max(DocumentConcreteDestructive.Fc) AS Fc_Max, StDev(DocumentConcreteDestructive.Fc) AS Fc_StDevP, Var(DocumentConcreteDestructive.Fc) AS Fc_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.Fc AS BIT) AS INT)) AS Fc_CountTrue, Count(DocumentConcreteDestructive.FieldSheetNo) AS FieldSheetNo_Count, Count(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Count, Avg(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Avg, Sum(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Sum, Min(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Min, Max(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_Max, StDev(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_StDevP, Var(DocumentConcreteDestructive.MeasuredAir) AS MeasuredAir_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredAir AS BIT) AS INT)) AS MeasuredAir_CountTrue, Count(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Count, Avg(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Avg, Sum(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Sum, Min(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Min, Max(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_Max, StDev(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_StDevP, Var(DocumentConcreteDestructive.MeasuredDensity) AS MeasuredDensity_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredDensity AS BIT) AS INT)) AS MeasuredDensity_CountTrue, Count(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Count, Avg(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Avg, Sum(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Sum, Min(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Min, Max(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_Max, StDev(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_StDevP, Var(DocumentConcreteDestructive.MeasuredSlump) AS MeasuredSlump_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.MeasuredSlump AS BIT) AS INT)) AS MeasuredSlump_CountTrue, Count(DocumentConcreteDestructive.ProductCode) AS ProductCode_Count, Count(DocumentConcreteDestructive.ProductName) AS ProductName_Count, Count(DocumentConcreteDestructive.ProjectCode) AS ProjectCode_Count, DocumentConcreteDestructive.ProjectName, Count(DocumentConcreteDestructive.QestID) AS QestID_Count, Avg(DocumentConcreteDestructive.QestID) AS QestID_Avg, Sum(DocumentConcreteDestructive.QestID) AS QestID_Sum, Min(DocumentConcreteDestructive.QestID) AS QestID_Min, Max(DocumentConcreteDestructive.QestID) AS QestID_Max, StDev(DocumentConcreteDestructive.QestID) AS QestID_StDevP, Var(DocumentConcreteDestructive.QestID) AS QestID_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.QestID AS BIT) AS INT)) AS QestID_CountTrue, Count(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Count, Avg(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Avg, Sum(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Sum, Min(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Min, Max(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_Max, StDev(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_StDevP, Var(DocumentConcreteDestructive.QestUniqueID) AS QestUniqueID_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.QestUniqueID AS BIT) AS INT)) AS QestUniqueID_CountTrue, Count(DocumentConcreteDestructive.SampleID) AS SampleID_Count, Count(DocumentConcreteDestructive.SourceCode) AS SourceCode_Count, Count(DocumentConcreteDestructive.SourceName) AS SourceName_Count, Count(DocumentConcreteDestructive.Specimens) AS Specimens_Count, Avg(DocumentConcreteDestructive.Specimens) AS Specimens_Avg, Sum(DocumentConcreteDestructive.Specimens) AS Specimens_Sum, Min(DocumentConcreteDestructive.Specimens) AS Specimens_Min, Max(DocumentConcreteDestructive.Specimens) AS Specimens_Max, StDev(DocumentConcreteDestructive.Specimens) AS Specimens_StDevP, Var(DocumentConcreteDestructive.Specimens) AS Specimens_VarP, Sum(CAST(CAST(DocumentConcreteDestructive.Specimens AS BIT) AS INT)) AS Specimens_CountTrue, Count(DocumentConcreteDestructive.SupplierCode) AS SupplierCode_Count, Count(DocumentConcreteDestructive.SupplierName) AS SupplierName_Count, Count(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_Count, Avg(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_Avg, Sum(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_Sum, Min(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_Min, Max(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_Max, StDev(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_StDevP, Var(DocumentConcreteDestructiveSpecimen.AgeDays) AS AgeDays_VarP, Sum(CAST(CAST(DocumentConcreteDestructiveSpecimen.AgeDays AS BIT) AS INT)) AS AgeDays_CountTrue, Count(DocumentConcreteDestructiveSpecimen.Density) AS Density_Count, Avg(DocumentConcreteDestructiveSpecimen.Density) AS Density_Avg, Sum(DocumentConcreteDestructiveSpecimen.Density) AS Density_Sum, Min(DocumentConcreteDestructiveSpecimen.Density) AS Density_Min, Max(DocumentConcreteDestructiveSpecimen.Density) AS Density_Max, StDev(DocumentConcreteDestructiveSpecimen.Density) AS Density_StDevP, Var(DocumentConcreteDestructiveSpecimen.Density) AS Density_VarP, Sum(CAST(CAST(DocumentConcreteDestructiveSpecimen.Density AS BIT) AS INT)) AS Density_CountTrue, Count(DocumentConcreteDestructiveSpecimen.FieldSheetAndID) AS FieldSheetAndID_Count, Count(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_Count, Avg(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_Avg, Sum(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_Sum, Min(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_Min, Max(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_Max, StDev(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_StDevP, Var(DocumentConcreteDestructiveSpecimen.QestID) AS QestIDDocumentConcreteDestructiveSpecimen_VarP, Sum(CAST(CAST(DocumentConcreteDestructiveSpecimen.QestID AS BIT) AS INT)) AS QestIDDocumentConcreteDestructiveSpecimen_CountTrue, Count(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_Count, Avg(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_Avg, Sum(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_Sum, Min(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_Min, Max(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_Max, StDev(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_StDevP, Var(DocumentConcreteDestructiveSpecimen.QestUniqueID) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_VarP, Sum(CAST(CAST(DocumentConcreteDestructiveSpecimen.QestUniqueID AS BIT) AS INT)) AS QestUniqueIDDocumentConcreteDestructiveSpecimen_CountTrue, Count(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_Count, Avg(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_Avg, Sum(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_Sum, Min(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_Min, Max(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_Max, StDev(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_StDevP, Var(DocumentConcreteDestructiveSpecimen.Strength_IP) AS Strength_IP_VarP, Sum(CAST(CAST(DocumentConcreteDestructiveSpecimen.Strength_IP AS BIT) AS INT)) AS Strength_IP_CountTrue, Count(DocumentConcreteDestructiveSpecimen.TestDate) AS TestDate_Count, Count(DocumentConcreteDestructiveSpecimen.TimeTested) AS TimeTested_Count, Count(DocumentConcreteDestructiveSpecimen.Type) AS Type_Count FROM DocumentConcreteDestructive LEFT JOIN DocumentConcreteDestructiveSpecimen ON DocumentConcreteDestructive.QestUniqueID = DocumentConcreteDestructiveSpecimen.QestUniqueParentID WHERE (DocumentConcreteDestructive.QestID = 1605 OR DocumentConcreteDestructive.QestID = 1602) AND ( DocumentConcreteDestructive.ClientCode = {''Client Code''(ClientCode:20001)} AND DocumentConcreteDestructive.ProjectCode = {''Project Code''(ProjectCode:20002)} AND DocumentConcreteDestructive.DateCast Between {#Date Cast#} AND DocumentConcreteDestructiveSpecimen.TestDate Between {#Test Date#} AND DocumentConcreteDestructive.ProductCode = {''Product Code''(ProductCode:20021)} AND DocumentConcreteDestructiveSpecimen.AgeDays Between {Age Days}) GROUP BY DocumentConcreteDestructive.ClientName,DocumentConcreteDestructive.ProjectName ORDER BY DocumentConcreteDestructive.ClientName,DocumentConcreteDestructive.ProjectName', 0, null, 0, 'RES - Concrete Compressive Strength - table', '', NULL, 'SELECT     DocumentConcreteDestructive.AcceptanceAge, DocumentConcreteDestructive.ClientCode, DocumentConcreteDestructive.ClientName, DocumentConcreteDestructive.COMP100AvgStrength_28, DocumentConcreteDestructive.COMP100AvgStrength_7, DocumentConcreteDestructive.DateCast, DocumentConcreteDestructive.Docket, DocumentConcreteDestructive.Fc, DocumentConcreteDestructive.FieldSheetNo, DocumentConcreteDestructive.LocationDescription, DocumentConcreteDestructive.MeasuredAir, DocumentConcreteDestructive.MeasuredDensity, DocumentConcreteDestructive.MeasuredSlump, DocumentConcreteDestructive.ProductCode, DocumentConcreteDestructive.ProductName, DocumentConcreteDestructive.ProjectCode, DocumentConcreteDestructive.ProjectName, DocumentConcreteDestructive.QestID, DocumentConcreteDestructive.QestUniqueID, DocumentConcreteDestructive.SampleID, DocumentConcreteDestructive.SourceCode, DocumentConcreteDestructive.SourceName, DocumentConcreteDestructive.Specimens, DocumentConcreteDestructive.SupplierCode, DocumentConcreteDestructive.SupplierName, DocumentConcreteDestructiveSpecimen.AgeDays, DocumentConcreteDestructiveSpecimen.Density, DocumentConcreteDestructiveSpecimen.FieldSheetAndID, DocumentConcreteDestructiveSpecimen.QestID AS QestIDDocumentConcreteDestructiveSpecimen, DocumentConcreteDestructiveSpecimen.QestUniqueID AS QestUniqueIDDocumentConcreteDestructiveSpecimen, DocumentConcreteDestructiveSpecimen.Strength_IP, DocumentConcreteDestructiveSpecimen.TestDate, DocumentConcreteDestructiveSpecimen.TimeTested, DocumentConcreteDestructiveSpecimen.Type FROM DocumentConcreteDestructive LEFT JOIN DocumentConcreteDestructiveSpecimen ON DocumentConcreteDestructive.QestUniqueID = DocumentConcreteDestructiveSpecimen.QestUniqueParentID WHERE (DocumentConcreteDestructive.QestID = 1605 OR DocumentConcreteDestructive.QestID = 1602) AND ( DocumentConcreteDestructive.ClientCode = {''Client Code''(ClientCode:20001)} AND DocumentConcreteDestructive.ProjectCode = {''Project Code''(ProjectCode:20002)} AND DocumentConcreteDestructive.DateCast Between {#Date Cast#} AND DocumentConcreteDestructiveSpecimen.TestDate Between {#Test Date#} AND DocumentConcreteDestructive.ProductCode = {''Product Code''(ProductCode:20021)} AND DocumentConcreteDestructiveSpecimen.AgeDays Between {Age Days}) ORDER BY  DocumentConcreteDestructive.ClientName, DocumentConcreteDestructive.ProjectName, DocumentConcreteDestructive.DateCast ASC, DocumentConcreteDestructive.QestUniqueID ASC, DocumentConcreteDestructiveSpecimen.AgeDays ASC', 0);
INSERT INTO @DataFilters(DefaultView,FilterGroup,Grouping,GroupSQL,HideObjectNodes,InternalName,Locked,Name,Properties,SearchCriteria,SQL,SQLEdit) VALUES('', 90000, 'SampleRegister.ProjectCode,', '', 0, null, 0, 'RES - Proctor Results', '', NULL, 'SELECT   qestObjects.Value as Method, DocumentMaximumDryDensity.AdjustedMDD, DocumentMaximumDryDensity.AdjustedOMC, DocumentMaximumDryDensity.HammerDescription, DocumentMaximumDryDensity.MaximumDryDensity, DocumentMaximumDryDensity.MethodUsed, DocumentMaximumDryDensity.OptimumMoistureContent, DocumentMaximumDryDensity.QestID AS QestIDDocumentMaximumDryDensity, DocumentMaximumDryDensity.Visual, WorkOrders.QestID AS QestIDWorkOrders, WorkOrders.TechnicianName, WorkOrders.WorkDate, SampleRegister.ProductName, SampleRegister.ProjectCode, SampleRegister.ProjectName, SampleRegister.QestID, SampleRegister.SampleID, SampleRegister.SourceCode, SampleRegister.SupplierCode, SampleRegister.LocationDescription, documentatterberglimits.liquidlimit, ISNULL(documentatterberglimits.plasticityindextext, ROUND(documentatterberglimits.plasticityindex, 0)) AS PLI,
ISNULL(documentatterberglimits.plasticlimittext, ROUND(documentatterberglimits.plasticlimit, 0)) AS PL FROM (SampleRegister LEFT JOIN WorkOrders ON SampleRegister.QestUniqueParentID = WorkOrders.QestUniqueID) LEFT JOIN DocumentMaximumDryDensity ON SampleRegister.QestUniqueID = DocumentMaximumDryDensity.QestUniqueParentID LEFT JOIN ListProject ON SampleRegister.ProjectCode = ListProject.ProjectCode LEFT JOIN DocumentAtterbergLimits ON SampleRegister.QestUniqueID =  DocumentAtterbergLimits.QestUniqueParentID LEFT JOIN qestObjects ON DocumentMaximumDryDensity.QestID = qestObjects.qestID WHERE qestObjects.Property = ''Method'' AND (WorkOrders.QestID Is Not NULL OR DocumentMaximumDryDensity.QestID Is Not NULL) AND WorkOrders.WorkDate Between {#Work Date#} AND ( SampleRegister.ProjectCode Like {''Project Code''(ProjectCode:20002)} AND SampleRegister.SupplierCode = {''Supplier Code''(SupplierCode:20027)} AND SampleRegister.SourceCode = {''Source Code''(SourceCode:20003)} AND DocumentMaximumDryDensity.MaximumDryDensity >= 0) AND (COALESCE(ListProject.Inactive,0) = 0 OR ListProject.Inactive = {Include Closed Projects}) ORDER BY  SampleRegister.ProjectCode, WorkOrders.WorkDate DESC', 1);

delete curr
from @DataFilters toAdd
inner join DataFilters curr on
	toAdd.Name = curr.Name and
	toAdd.FilterGroup = curr.FilterGroup
	
-- Execution
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- Temp variables for the cursor

DECLARE @DefaultView nvarchar(50);
DECLARE @FilterGroup int;
DECLARE @Grouping nvarchar(max);
DECLARE @GroupSQL nvarchar(max);
DECLARE @HideObjectNodes bit;
DECLARE @InternalName nvarchar(50);
DECLARE @Locked bit;
DECLARE @Name nvarchar(50);
DECLARE @Properties nvarchar(max);
DECLARE @SearchCriteria nvarchar(max);
DECLARE @SQL nvarchar(max);
DECLARE @SQLEdit bit;


DECLARE cur_DataFilters CURSOR FAST_FORWARD FOR
SELECT 
	DefaultView,
	FilterGroup,
	Grouping,
	GroupSQL,
	HideObjectNodes,
	InternalName,
	Locked,
	Name,
	Properties,
	SearchCriteria,
	SQL,
	SQLEdit

FROM @DataFilters;

OPEN cur_DataFilters;

FETCH NEXT FROM cur_DataFilters INTO 
	@DefaultView,
	@FilterGroup,
	@Grouping,
	@GroupSQL,
	@HideObjectNodes,
	@InternalName,
	@Locked,
	@Name,
	@Properties,
	@SearchCriteria,
	@SQL,
	@SQLEdit

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [dbo].[tempProc_AddToDataFilters] 
		@DefaultView = @DefaultView,
		@FilterGroup = @FilterGroup,
		@Grouping = @Grouping,
		@GroupSQL = @GroupSQL,
		@HideObjectNodes = @HideObjectNodes,
		@InternalName = @InternalName,
		@Locked = @Locked,
		@Name = @Name,
		@Properties = @Properties,
		@SearchCriteria = @SearchCriteria,
		@SQL = @SQL,
		@SQLEdit = @SQLEdit,
        @Verbose = @Verbose

FETCH NEXT FROM cur_DataFilters INTO 
	@DefaultView,
	@FilterGroup,
	@Grouping,
	@GroupSQL,
	@HideObjectNodes,
	@InternalName,
	@Locked,
	@Name,
	@Properties,
	@SearchCriteria,
	@SQL,
	@SQLEdit

END

CLOSE cur_DataFilters;
DEALLOCATE cur_DataFilters;


-- remove from the current reports if the names & filter names match
delete curr
from @Reports toAdd
inner join Reports curr on
	toAdd.Name = curr.Name and
	toAdd.QestID = curr.QestID and
	toAdd.FilterName = curr.FilterName and
	toAdd.ReportGroup = curr.ReportGroup

-- Execution
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-- Temp variables for the cursor

DECLARE @AlternateSpecification bit;
DECLARE @AlternateSpecificationName nvarchar(50);
DECLARE @Chart bit;
DECLARE @ChartSize1 smallint;
DECLARE @ChartSize2 smallint;
DECLARE @ChartSize3 smallint;
DECLARE @ChartSize4 smallint;
DECLARE @ChartSize5 smallint;
DECLARE @Columns nvarchar(max);
DECLARE @CustomReportObject nvarchar(255);
DECLARE @DetailFontBold bit;
DECLARE @DetailFontItalic bit;
DECLARE @DetailFontName nvarchar(50);
DECLARE @DetailFontSize real;
DECLARE @DifferenceValues bit;
DECLARE @DocumentNo nvarchar(50);
DECLARE @Fields nvarchar(max);
DECLARE @FilterName nvarchar(50);
DECLARE @GroupForLastN bit;
DECLARE @GroupNewPage bit;
DECLARE @HeaderFontBold bit;
DECLARE @HeaderFontItalic bit;
DECLARE @HeaderFontName nvarchar(50);
DECLARE @HeaderFontSize real;
DECLARE @IndentLeft real;
DECLARE @IndentRight real;
DECLARE @LastN nvarchar(50);
DECLARE @LastNDateField nvarchar(50);
DECLARE @LimitFontBold bit;
DECLARE @LimitFontColour int;
DECLARE @LimitFontItalic bit;
DECLARE @LimitShadingColour int;
DECLARE @LineEachRow bit;
DECLARE @LineHeight float;
--DECLARE @Locked bit;
--DECLARE @Name nvarchar(100);
DECLARE @Notes nvarchar(max);
DECLARE @Orientation smallint;
DECLARE @PageHeight float;
DECLARE @PageMarginBottom float;
DECLARE @PageMarginLeft float;
DECLARE @PageMarginRight float;
DECLARE @PageMarginTop float;
DECLARE @PageWidth float;
--DECLARE @Properties nvarchar(max);
DECLARE @QestCreatedBy int;
DECLARE @QestCreatedDate datetime;
DECLARE @QestID int;
DECLARE @QestModifiedBy int;
DECLARE @QestModifiedDate datetime;
DECLARE @QestOwnerLabNo int;
DECLARE @ReportGroup nvarchar(50);
DECLARE @ShowLimits bit;
DECLARE @StatsLine bit;
DECLARE @StatsOnly bit;
DECLARE @SubTitle nvarchar(max);
DECLARE @SubTitleFontBold bit;
DECLARE @SubTitleFontItalic bit;
DECLARE @SubTitleFontName nvarchar(50);
DECLARE @SubTitleFontSize real;
DECLARE @SuppressSearchCriteria bit;
DECLARE @Title nvarchar(255);
DECLARE @TitleFontBold bit;
DECLARE @TitleFontItalic bit;
DECLARE @TitleFontName nvarchar(50);
DECLARE @TitleFontSize real;


DECLARE cur_Reports CURSOR FAST_FORWARD FOR
SELECT 
	AlternateSpecification,
	AlternateSpecificationName,
	Chart,
	ChartSize1,
	ChartSize2,
	ChartSize3,
	ChartSize4,
	ChartSize5,
	Columns,
	CustomReportObject,
	DetailFontBold,
	DetailFontItalic,
	DetailFontName,
	DetailFontSize,
	DifferenceValues,
	DocumentNo,
	Fields,
	FilterName,
	GroupForLastN,
	GroupNewPage,
	HeaderFontBold,
	HeaderFontItalic,
	HeaderFontName,
	HeaderFontSize,
	IndentLeft,
	IndentRight,
	LastN,
	LastNDateField,
	LimitFontBold,
	LimitFontColour,
	LimitFontItalic,
	LimitShadingColour,
	LineEachRow,
	LineHeight,
	Locked,
	Name,
	Notes,
	Orientation,
	PageHeight,
	PageMarginBottom,
	PageMarginLeft,
	PageMarginRight,
	PageMarginTop,
	PageWidth,
	Properties,
	QestCreatedBy,
	QestCreatedDate,
	QestID,
	QestModifiedBy,
	QestModifiedDate,
	QestOwnerLabNo,
	ReportGroup,
	ShowLimits,
	StatsLine,
	StatsOnly,
	SubTitle,
	SubTitleFontBold,
	SubTitleFontItalic,
	SubTitleFontName,
	SubTitleFontSize,
	SuppressSearchCriteria,
	Title,
	TitleFontBold,
	TitleFontItalic,
	TitleFontName,
	TitleFontSize

FROM @Reports;

OPEN cur_Reports;

FETCH NEXT FROM cur_Reports INTO 
	@AlternateSpecification,
	@AlternateSpecificationName,
	@Chart,
	@ChartSize1,
	@ChartSize2,
	@ChartSize3,
	@ChartSize4,
	@ChartSize5,
	@Columns,
	@CustomReportObject,
	@DetailFontBold,
	@DetailFontItalic,
	@DetailFontName,
	@DetailFontSize,
	@DifferenceValues,
	@DocumentNo,
	@Fields,
	@FilterName,
	@GroupForLastN,
	@GroupNewPage,
	@HeaderFontBold,
	@HeaderFontItalic,
	@HeaderFontName,
	@HeaderFontSize,
	@IndentLeft,
	@IndentRight,
	@LastN,
	@LastNDateField,
	@LimitFontBold,
	@LimitFontColour,
	@LimitFontItalic,
	@LimitShadingColour,
	@LineEachRow,
	@LineHeight,
	@Locked,
	@Name,
	@Notes,
	@Orientation,
	@PageHeight,
	@PageMarginBottom,
	@PageMarginLeft,
	@PageMarginRight,
	@PageMarginTop,
	@PageWidth,
	@Properties,
	@QestCreatedBy,
	@QestCreatedDate,
	@QestID,
	@QestModifiedBy,
	@QestModifiedDate,
	@QestOwnerLabNo,
	@ReportGroup,
	@ShowLimits,
	@StatsLine,
	@StatsOnly,
	@SubTitle,
	@SubTitleFontBold,
	@SubTitleFontItalic,
	@SubTitleFontName,
	@SubTitleFontSize,
	@SuppressSearchCriteria,
	@Title,
	@TitleFontBold,
	@TitleFontItalic,
	@TitleFontName,
	@TitleFontSize

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [dbo].[tempProc_AddToReports] 
		@AlternateSpecification = @AlternateSpecification,
		@AlternateSpecificationName = @AlternateSpecificationName,
		@Chart = @Chart,
		@ChartSize1 = @ChartSize1,
		@ChartSize2 = @ChartSize2,
		@ChartSize3 = @ChartSize3,
		@ChartSize4 = @ChartSize4,
		@ChartSize5 = @ChartSize5,
		@Columns = @Columns,
		@CustomReportObject = @CustomReportObject,
		@DetailFontBold = @DetailFontBold,
		@DetailFontItalic = @DetailFontItalic,
		@DetailFontName = @DetailFontName,
		@DetailFontSize = @DetailFontSize,
		@DifferenceValues = @DifferenceValues,
		@DocumentNo = @DocumentNo,
		@Fields = @Fields,
		@FilterName = @FilterName,
		@GroupForLastN = @GroupForLastN,
		@GroupNewPage = @GroupNewPage,
		@HeaderFontBold = @HeaderFontBold,
		@HeaderFontItalic = @HeaderFontItalic,
		@HeaderFontName = @HeaderFontName,
		@HeaderFontSize = @HeaderFontSize,
		@IndentLeft = @IndentLeft,
		@IndentRight = @IndentRight,
		@LastN = @LastN,
		@LastNDateField = @LastNDateField,
		@LimitFontBold = @LimitFontBold,
		@LimitFontColour = @LimitFontColour,
		@LimitFontItalic = @LimitFontItalic,
		@LimitShadingColour = @LimitShadingColour,
		@LineEachRow = @LineEachRow,
		@LineHeight = @LineHeight,
		@Locked = @Locked,
		@Name = @Name,
		@Notes = @Notes,
		@Orientation = @Orientation,
		@PageHeight = @PageHeight,
		@PageMarginBottom = @PageMarginBottom,
		@PageMarginLeft = @PageMarginLeft,
		@PageMarginRight = @PageMarginRight,
		@PageMarginTop = @PageMarginTop,
		@PageWidth = @PageWidth,
		@Properties = @Properties,
		@QestCreatedBy = @QestCreatedBy,
		@QestCreatedDate = @QestCreatedDate,
		@QestID = @QestID,
		@QestModifiedBy = @QestModifiedBy,
		@QestModifiedDate = @QestModifiedDate,
		@QestOwnerLabNo = @QestOwnerLabNo,
		@ReportGroup = @ReportGroup,
		@ShowLimits = @ShowLimits,
		@StatsLine = @StatsLine,
		@StatsOnly = @StatsOnly,
		@SubTitle = @SubTitle,
		@SubTitleFontBold = @SubTitleFontBold,
		@SubTitleFontItalic = @SubTitleFontItalic,
		@SubTitleFontName = @SubTitleFontName,
		@SubTitleFontSize = @SubTitleFontSize,
		@SuppressSearchCriteria = @SuppressSearchCriteria,
		@Title = @Title,
		@TitleFontBold = @TitleFontBold,
		@TitleFontItalic = @TitleFontItalic,
		@TitleFontName = @TitleFontName,
		@TitleFontSize = @TitleFontSize,
        @Verbose = @Verbose

FETCH NEXT FROM cur_Reports INTO 
	@AlternateSpecification,
	@AlternateSpecificationName,
	@Chart,
	@ChartSize1,
	@ChartSize2,
	@ChartSize3,
	@ChartSize4,
	@ChartSize5,
	@Columns,
	@CustomReportObject,
	@DetailFontBold,
	@DetailFontItalic,
	@DetailFontName,
	@DetailFontSize,
	@DifferenceValues,
	@DocumentNo,
	@Fields,
	@FilterName,
	@GroupForLastN,
	@GroupNewPage,
	@HeaderFontBold,
	@HeaderFontItalic,
	@HeaderFontName,
	@HeaderFontSize,
	@IndentLeft,
	@IndentRight,
	@LastN,
	@LastNDateField,
	@LimitFontBold,
	@LimitFontColour,
	@LimitFontItalic,
	@LimitShadingColour,
	@LineEachRow,
	@LineHeight,
	@Locked,
	@Name,
	@Notes,
	@Orientation,
	@PageHeight,
	@PageMarginBottom,
	@PageMarginLeft,
	@PageMarginRight,
	@PageMarginTop,
	@PageWidth,
	@Properties,
	@QestCreatedBy,
	@QestCreatedDate,
	@QestID,
	@QestModifiedBy,
	@QestModifiedDate,
	@QestOwnerLabNo,
	@ReportGroup,
	@ShowLimits,
	@StatsLine,
	@StatsOnly,
	@SubTitle,
	@SubTitleFontBold,
	@SubTitleFontItalic,
	@SubTitleFontName,
	@SubTitleFontSize,
	@SuppressSearchCriteria,
	@Title,
	@TitleFontBold,
	@TitleFontItalic,
	@TitleFontName,
	@TitleFontSize

END

CLOSE cur_Reports;
DEALLOCATE cur_Reports;

-- End of the transaction
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('[dbo].[tempProc_AddToReports]') IS NOT NULL
	DROP PROCEDURE [dbo].[tempProc_AddToReports];
GO

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('[dbo].[tempProc_AddToDataFilters]') IS NOT NULL
	DROP PROCEDURE [dbo].[tempProc_AddToDataFilters];
GO

SET NOCOUNT OFF;
--ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
