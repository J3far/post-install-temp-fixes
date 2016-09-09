-------------------------------------------------------------------------
-- SQ06105
-- Removing reference to Atterberg Limit testst (11042 & 11043) methods (MRTS01 and MRTS05) 
-- 
-- This script will remove the methods (MRTS01 and MRTS05) referenced 
-- in Atterberg Limit tests (11042 & 11043)
-- 
-- Database: QESTLab
-- Created By: Salih AL Rashid
-- Created Date: 06 AUG 2015
-- Last Modified By: Salih AL Rashid
-- Last Modified: 06 AUG 2015
-- 
-- Version: 1.1
-- Change LOG
--	1.0 Original Version
--
-- Repeatability: Safe
-- Re-run Requirement: After DB Structure Update
-------------------------------------------------------------------------


BEGIN TRANSACTION

	UPDATE qestObjects
	SET Value = 'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,LinearShrinkage|ConePenetrationText,Liquid Limit (%),0.0,Q104D,ConePenetration|PlasticLimitText,Plastic Limit (%),>0.0,Q105,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,,PlasticityIndex|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,,WeightedPlasticIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,,WeightedLinearShrinkage|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'
	where QestID = 11043
	AND Property = 'ResultsFields'
	AND Value = 'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,LinearShrinkage|ConePenetrationText,Liquid Limit (%),0.0,Q104D,ConePenetration|PlasticLimitText,Plastic Limit (%),>0.0,Q105,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,,PlasticityIndex|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,MRTS01,WeightedPlasticIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,MRTS05,WeightedLinearShrinkage|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'

	UPDATE qestObjects
	SET Value = 'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,LinearShrinkage|ConePenetrationText,Liquid Limit (%),0.0,Q104A,ConePenetration|PlasticLimitText,Plastic Limit (%),>0.0,Q105,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,,PlasticityIndex|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,,WeightedPlasticIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,,WeightedLinearShrinkage|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'
	where QestID = 11042
	AND Property = 'ResultsFields'
	AND Value = 'LinearShrinkageText,Linear Shrinkage (%),0.0,Q106,LinearShrinkage|ConePenetrationText,Liquid Limit (%),0.0,Q104A,ConePenetration|PlasticLimitText,Plastic Limit (%),>0.0,Q105,PlasticLimit|PlasticityIndexText,Plasticity Index (%),0.0,,PlasticityIndex|WeightedPlasticIndexText,Weighted Plasticity Index (%),>0,MRTS01,WeightedPlasticIndex|WeightedLinearShrinkageText,Weighted Linear Shrinkage (%),>0,MRTS05,WeightedLinearShrinkage|SampleHistory,Sample History,>|MaterialSelection,Test performed on,>'
	
COMMIT TRANSACTION