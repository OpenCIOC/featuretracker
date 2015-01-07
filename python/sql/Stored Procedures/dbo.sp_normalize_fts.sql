CREATE PROCEDURE [dbo].[sp_normalize_fts] (@condition [nvarchar] (4000))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [FullTextSearch].[NormalizeFTS].[NormalizeRS]
GO
