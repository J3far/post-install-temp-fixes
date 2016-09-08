-------------------------------------------------------------------------
-- SQ07916
-- CRT Report to include 'Tested By'
-- 
-- This script will add a new reporting field to report 'Tested By' for 'FLEX' and 'FLEXC' Caltrans specimens 
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 13 APRL 2016
-- Last Modified By: Salih AL Rashid
-- Last Modified: 13 APRL 2016
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--  1.1 Fixed minor error in script
--
-- Repeatability: Unsafe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong15', Value = 'FieldName=Custom.PersonName(LabObject.[QestCrushedBy]);Prompt=Tested By;FieldType=2;Width=1531;DontDisplayEmptyField=T;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong15'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong16', Value = 'FieldName=[Marks];Prompt=Remarks;ValueFormat=;FieldType=2;Visible=Custom.ConcreteShowMarksOnly(''FLEX'');|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong16'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong17', Value = 'Visible=False;FieldName=QestCheckedBy;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong17'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong18', Value = 'Visible=False;FieldName=Certificate;PrintFlag=T;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong18'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong19', Value = 'Visible=False;FieldName=Type;PrintFlagValue=Custom.ConcreteBaseType(labobject)\=''FLEX'';|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong19'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong20', Value = 'Visible=False;FieldName=AgeDays;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong20'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong21', Value = 'Visible=False;FieldName=AcceptanceAge;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong21'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong22', Value = 'Visible=False;FieldName=Fc;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong22'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong23', Value = 'RecordSummaryResult=T;FieldType=2;IsConcreteStrength=T;FieldName=labobject.parent.[AvgStrength];PromptFieldName=labobject.parent.[AverageStrengthPrompt];ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''False'',''True'');|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong23'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong24', Value = 'IsGroup;FieldType=2;GroupValueField=AgeDays;IsConcreteStrength=T;FieldName=Custom.ConcreteAvgStrengthValue(labObject,labObject.[Type],(Custom.ReplaceNull(labObject.[AgeDays],0)),labObject.[ComplianceSpecimen]);PromptFieldName=Custom.ConcreteAvgStrengthPrompt(labObject,labObject.[Type],(Custom.ReplaceNull(labObject.[AgeDays],0)));ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''True'',''False'');|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong24'
	Update qestobjects set Property = 'CTFLRecordsResultsFieldsLong25', Value = 'RecordSummaryResult=T;FieldName=labobject.[Fc];Prompt=Required Strength (psi);ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''False'',''True'');FieldType=2;|' where qestID = 18947 and Property = 'CTFLRecordsResultsFieldsLong25'

	IF not EXISTS(SELECT * from qestobjects where QESTID =18947 and property ='CTFLRecordsResultsFieldsLong26')
	BEGIN
		insert into qestobjects (QestID,QestActive,QestExtra,Property,Value,ValueText) 
		Values(
				18947
				,1
				,0
				,'CTFLRecordsResultsFieldsLong26'
				,'IsGroup;FieldType=2;GroupValueField=AgeDays;FieldName=Custom.IIF(((Custom.Replacenull(labObject.[AgeDays],0)))\=((Custom.ReplaceNull(labObject.[AcceptanceAge],0))),labObject.[Fc], ''HiddenValue'');Prompt=Required Strength (psi);ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''True'',''False'');DisplayColon=F;'
				,NULL
			 )
	END
	ELSE
		Print 'Column ''CTFLRecordsResultsFieldsLong26'' exist in the dataabse, please contact SpectraQEST helpdesk for assistance'

	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong15', Value = 'FieldName=Custom.PersonName(LabObject.[QestCrushedBy]);Prompt=Tested By;FieldType=2;Width=1531;DontDisplayEmptyField=T;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong15'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong16', Value = 'FieldName=[Marks];Prompt=Remarks;ValueFormat=;FieldType=2;Visible=Custom.ConcreteShowMarksOnly(''FLEXC'');|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong16'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong17', Value = 'Visible=False;FieldName=QestCheckedBy;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong17'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong18', Value = 'Visible=False;FieldName=Certificate;PrintFlag=T;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong18'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong19', Value = 'Visible=False;FieldName=Type;PrintFlagValue=Custom.ConcreteBaseType(labobject)\=''FLEXC'';|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong19'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong20', Value = 'Visible=False;FieldName=AgeDays;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong20'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong21', Value = 'Visible=False;FieldName=AcceptanceAge;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong21'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong22', Value = 'Visible=False;FieldName=Fc;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong22'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong23', Value = 'RecordSummaryResult=T;FieldType=2;IsConcreteStrength=T;FieldName=labobject.parent.[AvgStrength];PromptFieldName=labobject.parent.[AverageStrengthPrompt];ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''False'',''True'');|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong23'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong24', Value = 'IsGroup;FieldType=2;GroupValueField=AgeDays;IsConcreteStrength=T;FieldName=Custom.ConcreteAvgStrengthValue(labObject,labObject.[Type],(Custom.ReplaceNull(labObject.[AgeDays],0)),labObject.[ComplianceSpecimen]);PromptFieldName=Custom.ConcreteAvgStrengthPrompt(labObject,labObject.[Type],(Custom.ReplaceNull(labObject.[AgeDays],0)));ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''True'',''False'');|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong24'
	Update qestobjects set Property = 'CTFLCRecordsResultsFieldsLong25', Value = 'RecordSummaryResult=T;FieldName=labobject.[Fc];Prompt=Required Strength (psi);ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''False'',''True'');FieldType=2;|' where qestID = 18947 and Property = 'CTFLCRecordsResultsFieldsLong25'


	IF not EXISTS(SELECT * from qestobjects where QESTID =18947 and property ='CTFLCRecordsResultsFieldsLong26')
	BEGIN
		insert into qestobjects (QestID,QestActive,QestExtra,Property,Value,ValueText) 
		Values(
				18947
				,1
				,0
				,'CTFLCRecordsResultsFieldsLong26'
				,'IsGroup;FieldType=2;GroupValueField=AgeDays;FieldName=Custom.IIF(((Custom.Replacenull(labObject.[AgeDays],0)))\=((Custom.ReplaceNull(labObject.[AcceptanceAge],0))),labObject.[Fc], ''HiddenValue'');Prompt=Required Strength (psi);ValueFormat=10rb;RecordAlignColumn=Strength_IP;Visible=Custom.IIF(Custom.TextToBool(Custom.DocumentOptionValue(g_objlabObject.parent,''Use Compliance Ages'')),''True'',''False'');DisplayColon=F;'
				,NULL
			 )
	END
	ELSE
		Print 'Column ''CTFLRecordsResultsFieldsLong26'' exist in the dataabse, please contact SpectraQEST helpdesk for assistance'

commit