CREATE FUNCTION [dbo].[fn_normalize_fts] (@condition [nvarchar] (4000))
RETURNS [nvarchar] (4000)
WITH EXECUTE AS CALLER
EXTERNAL NAME [FullTextSearch].[NormalizeFTS].[Normalize]
GO
