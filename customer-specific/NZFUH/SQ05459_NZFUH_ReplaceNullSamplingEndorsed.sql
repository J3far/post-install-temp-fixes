-- SQ05459_NZFUH_ReplaceNullSamplingEndored.sql
--
-- Coded by: Nathan Bennett
-- Last Modified: 24-07-2015
--
-- This script adjusts the custom "Sampling Endorsed" fields to report NULL values as 'No'.

BEGIN TRANSACTION

UPDATE [dbo].[Options] SET OptionValue = REPLACE(OptionValue,'FieldName=g_objLabObject.[SamplingAccredited];','FieldName=Custom.ReplaceNull(g_objLabObject.[SamplingAccredited],''False'');') WHERE OptionKey LIKE '%Sample Fields' AND OptionValue LIKE '%FieldName=g_objLabObject.\[SamplingAccredited\];%' ESCAPE '\'

COMMIT TRANSACTION
