------------------------------------------------------------------------------------------------------------------------------------------------
-- SQ07583
-- Sripts for Atterber Screens

-- This script updates the reporting methods on the following Atterberg Screens
-- 10046,11042 and 11043

-- Database: QESTLab
-- Created By : Jafar AL Rashid
-- Created Date : 09/02/2016

-- Version: 1.0
-- Change Log
--- 1.0 Original Version

-- Repeatability: Safe
-- Re-Run Requirement: Re-run after any database update.
------------------------------------------------------------------------------------------------------------------------------------------------
begin tran
declare @QESTObjects table(
qestid int,
Property nvarchar(100),
Value nvarchar(max),
NewValue nvarchar(max)
)

insert into @QestObjects (QestID,Value,Property,NewValue) select 10046,'LinearShrinkageText,Linear Shrinkage (%),0.0,LinearShrinkageMethod,LinearShrinkage|LiquidLimitText,Liquid Limit (%),0.0,LiquidLimitMethod,LiquidLimit|PlasticLimitText,Plastic Limit (%),0.0,PlasticLimitMethod,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,PlasticityIndexMethod,PlasticityIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage,0,PlasticityIndexMethod,WeightedLinearShrinkage|WeightedPlasticityIndexText,Weighted Plasticity Index,0,PlasticityIndexMethod,WeightedPlasticityIndex', 'ResultsFields','LinearShrinkageText,Linear Shrinkage (%),0.0,LinearShrinkageMethod,LinearShrinkage|LiquidLimitText,Liquid Limit (%),0.0,LiquidLimitMethod,LiquidLimit|PlasticLimitText,Plastic Limit (%),0.0,PlasticLimitMethod,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,PlasticityIndexMethod,PlasticityIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage,0,Q106,WeightedLinearShrinkage|WeightedPlasticityIndexText,Weighted Plasticity Index,0,Q105,WeightedPlasticityIndex'
insert into @QestObjects (QestID,Value,Property,NewValue) select 11042,'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,|ConePenetrationText,Liquid Limit (%),0.0,Q104A,|PlasticLimitText,Plastic Limit (%),>0.0,Q105,|PlasticityIndexText,Plasticity Index (%),0.0|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,MRS 11.05|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>', 'ResultsFields','LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,|ConePenetrationText,Liquid Limit (%),0.0,Q104A,|PlasticLimitText,Plastic Limit (%),>0.0,Q105,|PlasticityIndexText,Plasticity Index (%),0.0|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,Q105|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,Q106|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'
insert into @QestObjects (QestID,Value,Property,NewValue) select 11043,'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106|ConePenetrationText,Liquid Limit (%),0.0,Q104D,|PlasticLimitText,Plastic Limit (%),>0.0,Q105,|PlasticityIndexText,Plasticity Index (%),0.0|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,MRS 11.05|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>', 'ResultsFields','LinearShrinkageText,Linear Shrinkage (%),0.0,Q106|ConePenetrationText,Liquid Limit (%),0.0,Q104D,|PlasticLimitText,Plastic Limit (%),>0.0,Q105,|PlasticityIndexText,Plasticity Index (%),0.0|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,Q105|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,Q106|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'

update c
set c.value = n.NewValue -- to reset to original values, use n.Value instead
from @QESTObjects n
inner join qestObjects c on n.qestid = c.QestID and n.Property = c.Property

commit