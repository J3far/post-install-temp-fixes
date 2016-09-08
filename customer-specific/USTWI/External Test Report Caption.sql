--Changes the caption of External Test Reports to use the custom Identification field
-- Needs to be run after every DB update/upgrade

UPDATE qestObjects 
SET 
--[Value] = '{Name} ({ReportNo})'
[Value] = '{_Identification?{_Identification} ({ReportNo}):{Name} ({ReportNo})}'
WHERE [Property] = 'Caption'
AND QestID = 18210