-------------------------------------------------------------------------
-- SQ06702
-- Change name for a Bind Properties - AU-IM006206307
-- 
-- This script will change the 'List' field for the 'Binder Absorbed Form' field
-- on the Bulk entry from 'Q211|Q214A or Q214B|Q316' to 'Q211|Q214A and Q214B|Q316' 
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 25 NOV 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 25 NOV 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------
begin tran
	update qestDisplayObjectDetails 
	set List='Q211|Q214A and Q214B|Q316'
	where FieldName like '%AbsorptionMethod%'
	and convert(nvarchar(max),List)=N'Q211|Q214A or Q214B|Q316'
commit
