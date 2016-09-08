-------------------------------------------------------------------------
-- SQ06974
-- Q211 Method reported when not selected
-- 
-- This script will hide Binder Absorbed (%) field in the report if it is not used or set to 0
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 13 NOV 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 13 NOV 2015
-- 
-- Version: 1.0
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------

begin tran
	update qestObjects
	set value = 'BinderAbsorbed,Binder Absorbed (%),>0.00,AbsorptionMethod|AirVoids,Air Voids (%),>0.0|VMA,Voids in Mineral Aggregate (%),>0.0|VFB,Voids Filled with Binder (%),>0.0'
	where qestID = 17089
	AND Property='ResultsFields' and value = 'BinderAbsorbed,Binder Absorbed (%),0.00,AbsorptionMethod|AirVoids,Air Voids (%),>0.0|VMA,Voids in Mineral Aggregate (%),>0.0|VFB,Voids Filled with Binder (%),>0.0'
commit