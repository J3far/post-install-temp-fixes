-------------------------------------------------------------------------
-- SQ07912
-- Workaround for User Doc Reports Locking When Printed
-- 
-- This script will set the option "Complete if Signed and Printed" true
--  for all existing user document test reports.
-- This is a workaround for the issue where user document test reports
--  were locking when printed.
-- 
-- Database: QESTLab
-- Created By: Nathan Bennett
-- Created Date: 01 Apr 2016
-- Last Modified By: Nathan Bennett
-- Last Modified: 04 Apr 2016
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Run once
-------------------------------------------------------------------------
BEGIN TRANSACTION

-- Create procedure to set "Complete if Signed and Printed" for new user document test reports
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.qest_Workaround_SetCompleteIfSignedAndPrintedOptionForNewUserDocReport'))
   exec sp_executesql N'DROP PROCEDURE [dbo].[qest_Workaround_SetCompleteIfSignedAndPrintedOptionForNewUserDocReport]'
GO

CREATE PROCEDURE [dbo].[qest_Workaround_SetCompleteIfSignedAndPrintedOptionForNewUserDocReport] 
	@QestID int
AS
	SET NOCOUNT ON;
	IF NOT EXISTS(SELECT * FROM Options WHERE OptionKey = '\QLO\Document.' + CAST(@QestID as varchar(10)) + '\Complete if Signed and Printed')
		INSERT INTO Options (OptionKey, OptionValue, QestID, OptionName) VALUES ('\QLO\Document.' + CAST(@QestID as varchar(10)) + '\Complete if Signed and Printed', 'Yes',@QestID,'Complete if Signed and Printed')
	ELSE
		UPDATE Options SET OptionValue = 'Yes' WHERE OptionKey Like '%Complete if Signed and Printed' and QestID = @QESTID
	
	-- Add to qestObjects to make this configurable in the QAC
	-- By default no options are available for User Documents so just an Insert will do.
	IF NOT EXISTS(SELECT * FROM qestObjects WHERE QestID = @QestID AND Property = 'Options')
		INSERT INTO qestObjects (QestId, QestActive, Property, Value, QestExtra) VALUES (@QestID, 1, 'Options','Complete if Signed and Printed,List:Yes;No',0)
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.qest_Workaround_SetCompleteIfSignedAndPrintedOptionForNewUserDocReport'))
BEGIN
	DECLARE @UserDocID INT, @QestID INT
	DECLARE @UserDocReportCursor CURSOR

	SET @UserDocReportCursor = CURSOR FOR
		SELECT QestID FROM UserDocuments WHERE Object like '%Classification=TestReport%'
		--Note: though the column is labelled QestID, it contains the raw user document ID

	OPEN @UserDocReportCursor
	FETCH NEXT FROM @UserDocReportCursor INTO @UserDocID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @QestID = @UserDocID + 19000
		EXEC dbo.qest_Workaround_SetCompleteIfSignedAndPrintedOptionForNewUserDocReport @QestID
		FETCH NEXT FROM @UserDocReportCursor INTO @UserDocID
	END

	CLOSE @UserDocReportCursor
	DEALLOCATE @UserDocReportCursor
END

COMMIT TRANSACTION


