SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Enhancement_Form]
	@ENHANCEMENT_ID [int],
	@ExtraSeeAlso varchar(max) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 24-Aug-2012
	Action: NO ACTION REQUIRED
*/

SELECT e.*
	FROM Enhancement e
WHERE e.ID=@ENHANCEMENT_ID

SELECT p.PRIORITY_ID, p.PriorityCode
	FROM Priority p
ORDER BY p.Weight

SELECT es.ESTIMATE_ID, es.EstimateCode
	FROM Estimate es
ORDER BY es.HrsLow

SELECT f.*
	FROM Funder f
	
SELECT st.*
	FROM [Status] st
	
SELECT src.*
	FROM SourceType src

SELECT k.*,
		CAST(CASE WHEN ek.KEYWORD_ID IS NULL THEN 0 ELSE 1 END AS bit) AS IS_SELECTED
	FROM Keyword k
	LEFT JOIN EnhancementKeyword ek
		ON k.KEYWORD_ID=ek.KEYWORD_ID AND ek.ENHANCEMENT_ID=@ENHANCEMENT_ID
ORDER BY k.Keyword

SELECT m.*,
		CAST(CASE WHEN em.MODULE_ID IS NULL THEN 0 ELSE 1 END AS bit) AS IS_SELECTED
	FROM Module m
	LEFT JOIN EnhancementModule em
		ON m.MODULE_ID=em.MODULE_ID AND em.ENHANCEMENT_ID=@ENHANCEMENT_ID

SELECT r.*,
		CAST(CASE WHEN er.RELEASE_ID IS NULL THEN 0 ELSE 1 END AS bit) AS IS_SELECTED
	FROM Release r
	LEFT JOIN EnhancementRelease er
		ON r.RELEASE_ID=er.RELEASE_ID AND er.ENHANCEMENT_ID=@ENHANCEMENT_ID
		
SELECT e.ID, e.Title
	FROM Enhancement e
	LEFT JOIN EnhancementSeeAlso es
		ON e.ID=es.SEE_ALSO_ID AND es.ENHANCEMENT_ID=@ENHANCEMENT_ID
	LEFT JOIN fn_ParseIntIDList(@ExtraSeeAlso, ',') extra
		ON e.ID=extra.ItemID
	WHERE es.SEE_ALSO_ID IS NOT NULL OR extra.ItemID IS NOT NULL

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_Enhancement_Form] TO [web_user_role]
GO
