-----------------------------------------------------------------------------------------------------------
-- SQ06060
-- QESTLab 4.1 - New List Behavior (Script)

-- Set NULL and blank Supplier Codes and Source Codes in ListSource and ListProduct to '(all)' 
-- to emulate list behaviour pre-4.1.400
-- Ref. bug #1648
--
-- WARNING: This script is intended for use with QESTLab 4.1.400 and later only
--
-- Database:          QESTLab
-- Created By:		  Christopher Kerr
-- Date Authored:	  31 July 2015
-- Last Modified By:  Christopher Kerr
-- Last Modified:	  03 August 2015
--
-- Version: 1.1
-- Change Log:
--		1.0 -	Original Version
--		1.1 -	Update header to match new standard, add transaction
--
-- Repeatability: Safe
-- Re-run Requirement: Once-off
-----------------------------------------------------------------------------------------------------------

begin transaction

update ListSource
set
	SupplierCode = '(all)'
	, Supplier = '(all)'
where 
	(SupplierCode is null or SupplierCode = '') 
	and (Supplier is null or Supplier = '')

update ListProduct
set
	SupplierCode = '(all)'
	, SupplierName = '(all)'
where 
	(SupplierCode is null or SupplierCode = '') 
	and (SupplierName is null or SupplierName = '')


update ListProduct
set
	SourceCode = '(all)'
	, SourceName = '(all)'
where 
	(SourceCode is null or SourceCode = '') 
	and (SourceName is null or SourceName = '')

commit transaction