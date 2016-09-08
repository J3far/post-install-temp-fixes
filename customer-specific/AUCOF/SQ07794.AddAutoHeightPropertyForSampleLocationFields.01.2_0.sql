-------------------------------------------------------------------------
-- SQ07794
-- Add AutoHeight Property For Sample Location Fields
-- 
-- Adds AutoHeight property for the sample location fields
--  on a number of reports (as named in support request):
--     Relative Compaction Report [RMS Wet - 2011] (ID 18913)
--     Dry Density Ratio Report (ID 18993)
--     HILF Density Ratio Report (ID 18996)
-- 
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 07 Mar 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 08 Mar 2016
-- 
-- Version: 2.0
-- Change LOG
--	1.0 Original Version
--  2.0 Added correction to reported fields of 18913
--
-- Repeatability: Safe
-- Re-run Requirement: Always run after QESTNET.Upgrade
-------------------------------------------------------------------------

BEGIN TRANSACTION

-- Create procedure to add an attribute to a results field long property of a qest object (only if it doesn't exist)
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'qest_AddAttributeToResultsFields_TEMP' AND SPECIFIC_SCHEMA = 'dbo' AND ROUTINE_TYPE = 'PROCEDURE')
BEGIN
    DROP PROCEDURE [dbo].[qest_AddAttributeToResultsFields_TEMP]
END
GO

CREATE PROCEDURE [dbo].[qest_AddAttributeToResultsFields_TEMP]
	@QestID int,
	@ResultsFieldsLongProperty nvarchar(32),
	@NewAttributeName nvarchar(200),
	@NewAttributeValue nvarchar(200)
AS
BEGIN
	-- Check if property exists where an attribute with that name hasn't already been set.
	IF EXISTS(SELECT * FROM QestObjects where QestID = @QestID and Property = @ResultsFieldsLongProperty and Value Not Like '%[=;]' + @NewAttributeName + '=%')
	BEGIN
		DECLARE @PropertyValue nvarchar(4000)
		SELECT @PropertyValue = Value FROM QestObjects WHERE QestID = @QestID and Property = @ResultsFieldsLongProperty 

		--Remove trailing pipe if present.
		IF (right(@PropertyValue,1) = '|') SET  @PropertyValue = substring(@PropertyValue,1,len(@PropertyValue)-1)
		-- Make sure there's an unescaped semi-colon before this attribute
		IF (right(@PropertyValue,2) not like '[^\];')  SET @PropertyValue = @PropertyValue + ';'
		-- Insert the new attribute
		SET @PropertyValue = @PropertyValue + @NewAttributeName + '=' + @NewAttributeValue + ';'
		-- End with pipe (no harm in adding this if it wasn't there before)
		SET @PropertyValue = @PropertyValue + '|'

		UPDATE QestObjects SET Value = @PropertyValue WHERE QestID = @QestID and Property = @ResultsFieldsLongProperty 
	END
END
GO

-- First we have to add the fifth LocationDescription field for 18913 if not already done
IF ((SELECT Value FROM QestObjects WHERE QestID = 18913 AND Property = 'SampleDetailsLong11') Like '%SampleCondition%')
BEGIN
	UPDATE qestObjects set Property = 'SampleDetailsLong15' WHERE Property = 'SampleDetailsLong14' AND QestID = 18913
	UPDATE qestObjects set Property = 'SampleDetailsLong14' WHERE Property = 'SampleDetailsLong13' AND QestID = 18913
	UPDATE qestObjects set Property = 'SampleDetailsLong13' WHERE Property = 'SampleDetailsLong12' AND QestID = 18913
	UPDATE qestObjects set Property = 'SampleDetailsLong12' WHERE Property = 'SampleDetailsLong11' AND QestID = 18913
	INSERT INTO dbo.qestObjects(QestID,QestActive,QestExtra,[Property],[Value]) VALUES(18913,1,0,'SampleDetailsLong11','Prompt= ;FieldName=LocationDescription;Index=4;Delimiter=,;PromptPath=../;PromptFieldName=LocationDescriptionFieldLabels;PromptIndex=4|')
END

exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18913, 'SampleDetailsLong7', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18913, 'SampleDetailsLong8', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18913, 'SampleDetailsLong9', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18913, 'SampleDetailsLong10', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18913, 'SampleDetailsLong11', 'AutoHeight', 'T'

exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18993, 'SampleDetailsLong6', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18993, 'SampleDetailsLong7', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18993, 'SampleDetailsLong8', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18993, 'SampleDetailsLong9', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18993, 'SampleDetailsLong10', 'AutoHeight', 'T'

exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18996, 'SampleDetailsLong6', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18996, 'SampleDetailsLong7', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18996, 'SampleDetailsLong8', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18996, 'SampleDetailsLong9', 'AutoHeight', 'T'
exec [dbo].[qest_AddAttributeToResultsFields_TEMP] 18996, 'SampleDetailsLong10', 'AutoHeight', 'T'

-- Create procedure to add a property to a results field (only if it doesn't exist)
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'qest_AddAttributeToResultsFields_TEMP' AND SPECIFIC_SCHEMA = 'dbo' AND ROUTINE_TYPE = 'PROCEDURE')
BEGIN
    DROP PROCEDURE [dbo].[qest_AddAttributeToResultsFields_TEMP]
END
GO

COMMIT TRANSACTION