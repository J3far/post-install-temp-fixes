-------------------------------------------------------------------------
-- SQ06947
-- 4.1.1000 Bug - Wheel Tracking Test
-- 
-- Create a trigger to set ID = SlabID
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

IF EXISTS (SELECT * FROM sys.objects WHERE [type] = 'TR' AND [name] = 'TR_DocumentWheelTrackingSingle_update_ID')
    DROP TRIGGER [dbo].[TR_DocumentWheelTrackingSingle_update_ID];
GO

CREATE TRIGGER [dbo].[TR_DocumentWheelTrackingSingle_update_ID]
			ON [dbo].[DocumentWheelTrackingSingle] AFTER INSERT, UPDATE
			AS
				UPDATE DocumentWheelTrackingSingle
				SET ID = dts.SlabID
				FROM DocumentWheelTrackingSingle dts
				INNER JOIN inserted i on dts.QestID = i.QestID and dts.QestUniqueID = i.QestUniqueID
GO