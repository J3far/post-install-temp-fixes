----------------------------------------------------------------------------------------------------------------------------
-- SQ08136
-- Repairs existing 'non-constant mass drying record' Atterberg tests, which are not correctly flagged as 'non-constant mass drying record'
--
-- Sets the DryRecord flag off (0), if the Dry Mass exists, but no Dry Mass Records exist, and if the DryRecord flag is null
--
-- Created By: Shane Rowley
-- Created Date: 29-Apr-2016
--
-- Version 1.0
-- Change Log
--  1.0 Original Version
--
-- Repeatability: Safe
-- Re-Run Requirement: Once. 
----------------------------------------------------------------------------------------------------------------------------
begin tran

update a
set DryRecord = 0
from DocumentAtterbergLimits a inner join DocumentAtterbergLimitsSpecimen s on a.QestUniqueID = s.QestUniqueParentID and a.QestID = s.QestParentID 
where a.DryRecord is null and s.DryRecord1 is null and s.DryRecord2 is null and s.DryRecord3 is null and s.ContainerAndDrySoilMass is not null

commit