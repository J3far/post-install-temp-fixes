-------------------------------------------------------------------------
-- SQ06947
-- 4.1.1000 Bug - Wheel Tracking Test
-- 
-- Create a new column called 'ID' in DocumentWheelTrackingSingle table
-- 
-- Database: QESTLab
-- Created By: Salih Al Rashid
-- Created Date: 07 DEC 2015
-- Last Modified By: Salih Al Rashid
-- Last Modified: 07 DEC 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: Once-off
-------------------------------------------------------------------------

IF not EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'ID' AND Object_ID = Object_ID(N'DocumentWheelTrackingSingle'))
	alter table DocumentWheelTrackingSingle
	add ID nvarchar(50)
GO
