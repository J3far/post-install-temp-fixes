----------------------------------------------------------------------
-- SQ05338_NZFUH_RemoveCAN12W2947.sql
--
-- Author: Nathan Bennett
-- Date Modified: 5th May 2015
-- Description:
--  SQ05338 - Deletes corrupted work order CAN12W3947 and all related entries
----------------------------------------------------------------------

BEGIN transaction

DELETE FROM [dbo].[WorkOrders] WHERE QestUniqueID = 65747

DELETE FROM [dbo].[qestReverseLookup] WHERE QestUniqueID = 65747 AND QestID = 101

COMMIT transaction
