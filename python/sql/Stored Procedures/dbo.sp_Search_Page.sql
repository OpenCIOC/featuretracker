SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Search_Page]
	@UserEmail [varchar](60)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.2
	Checked by: KL
	Checked on: 04-Jun-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @NEUTRAL_PRIORITY smallint
SELECT @NEUTRAL_PRIORITY=PRIORITY_ID FROM Priority WHERE PriorityCode='NEUTRAL'

SELECT k.*, COUNT(s.STATUS_ID) AS EnhancementCount
	FROM Keyword k
	LEFT JOIN EnhancementKeyword ek
		ON k.KEYWORD_ID=ek.KEYWORD_ID
	LEFT JOIN Enhancement e 
		ON ek.ENHANCEMENT_ID=e.ID
	LEFT JOIN [Status] s
		ON e.SYS_STATUS=s.STATUS_ID AND s.ShowByDefault=1
GROUP BY k.KEYWORD_ID, k.Keyword
HAVING COUNT(ek.KEYWORD_ID) > 0
ORDER BY k.Keyword

SELECT *
	FROM Module m
	
SELECT p.PRIORITY_ID, p.PriorityCode, p.PriorityName, p.Weight,
	(SELECT COUNT(*) FROM Enhancement e INNER JOIN [Status] s ON e.SYS_STATUS=s.STATUS_ID AND s.ShowByDefault=1
		WHERE e.SYS_PRIORITY=p.PRIORITY_ID) AS SysEnhancementCount,
	(SELECT COUNT(*) FROM Enhancement e INNER JOIN [Status] s ON e.SYS_STATUS=s.STATUS_ID AND s.ShowByDefault=1
		LEFT JOIN (SELECT ENHANCEMENT_ID, PRIORITY_ID FROM UserEnhancementPriority WHERE [USER_ID] = (SELECT u.USER_ID FROM UserAccount u WHERE u.Email=@UserEmail)) uep
			ON e.ID=uep.ENHANCEMENT_ID
		WHERE uep.PRIORITY_ID=p.PRIORITY_ID OR (uep.ENHANCEMENT_ID IS NULL AND p.PRIORITY_ID=@NEUTRAL_PRIORITY)) AS UserEnhancementCount
	FROM Priority p
GROUP BY p.PRIORITY_ID, p.PriorityCode, p.PriorityName, p.[Weight]
ORDER BY p.[Weight] DESC

SELECT es.ESTIMATE_ID, ISNULL('$' + CAST(es.CostLow AS varchar) + ' - $' + CAST(es.CostHigh AS varchar),EstimateCode) AS CostRange, COUNT(s.STATUS_ID) AS EnhancementCount
	FROM Estimate es
	LEFT JOIN Enhancement e
		ON es.ESTIMATE_ID=e.SYS_ESTIMATE
	LEFT JOIN [Status] s
		ON e.SYS_STATUS=s.STATUS_ID AND s.ShowByDefault=1
GROUP BY es.ESTIMATE_ID, es.EstimateCode, es.CostHigh, es.CostLow, es.HrsLow
HAVING COUNT(e.ID) > 0
ORDER BY CASE WHEN CostLow IS NULL THEN 1 ELSE 0 END, HrsLow

SELECT r.RELEASE_ID, r.ReleaseName, COUNT(er.ENHANCEMENT_ID) AS EnhancementCount
	FROM Release r
	INNER JOIN EnhancementRelease er
		ON r.RELEASE_ID=er.RELEASE_ID
GROUP BY r.RELEASE_ID, r.ReleaseName
ORDER BY r.ReleaseName

SELECT f.FUNDER_ID, f.FunderName, COUNT(e.ID) AS EnhancementCount
	FROM Funder f
	INNER JOIN Enhancement e
		ON f.FUNDER_ID=e.SYS_FUNDER
GROUP BY f.FUNDER_ID, f.FunderName
UNION SELECT -1 AS FUNDER_ID, 'None' AS FunderName, (SELECT COUNT(*) FROM Enhancement e WHERE SYS_FUNDER IS NULL) AS EnhancementCount
ORDER BY f.FunderName

SELECT s.STATUS_ID, s.StatusName, COUNT(e.ID) AS EnhancementCount
	FROM Status s
	INNER JOIN Enhancement e
		ON s.STATUS_ID=e.SYS_STATUS
GROUP BY s.STATUS_ID, s.StatusName
ORDER BY s.StatusName

IF @UserEmail IS NOT NULL BEGIN
	EXEC sp_User_Priorities @UserEmail
	EXEC sp_User_Cart @UserEmail
END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_Search_Page] TO [web_user_role]
GO
