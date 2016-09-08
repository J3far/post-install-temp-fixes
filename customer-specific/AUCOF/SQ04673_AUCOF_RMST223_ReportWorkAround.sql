--Author: Vu Le
--Purpose: [SQ04673] Cof14.114  Remove Grading Rock Strength - Point Load [RMS T223][11304] 
--			The script will add a dummy ResultsFields to the test qestObject, so that the test will appear in the list of tests of the report
--			To let the be test editable after the report has been signed, untick the test from the report
--Can be run multiple times


begin transaction
if not exists(select QestUniqueID from qestObjects where QestID = 11304 and Property = 'ResultsFields')
begin
	insert into qestObjects (QestID, QestActive, QestExtra, Property, Value) values (11304, 1, 0, 'ResultsFields', 'SampleID,,""')
end
commit transaction