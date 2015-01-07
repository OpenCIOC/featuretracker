SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Enhancement_Detail]
	@UserEmail [varchar](60),
	@ENHANCEMENT_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.2
	Checked by: KL
	Checked on: 03-Jun-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@UserEmail

SELECT e.ID,
	e.Title,
	e.BasicDescription,
	e.AdditionalNotes,
	dbo.fn_DateString(e.MODIFIED_DATE) AS LastModified,
	e.MODIFIED_BY AS ModifiedBy,
	s.StatusName AS [Status],
	(SELECT f.FunderName FROM Funder f WHERE f.FUNDER_ID=e.SYS_FUNDER) AS Funder,
	(SELECT COUNT(*) FROM UserEnhancementPriority uep INNER JOIN UserAccount u ON uep.USER_ID=u.USER_ID WHERE u.NotCounted=0 AND ENHANCEMENT_ID=e.ID) AS RankedByUsers,
	(SELECT COUNT(DISTINCT u.MEMBER_ID) FROM UserEnhancementPriority uep INNER JOIN UserAccount u ON uep.USER_ID=u.USER_ID WHERE u.NotCounted=0 AND ENHANCEMENT_ID=e.ID) AS RankedByMembers,
	(SELECT TOP 1 p.* FROM Priority p
		WHERE p.Weight=ROUND(
			(SELECT AVG(CAST(p.Weight AS decimal(4,2)))
				FROM UserEnhancementPriority uep
				INNER JOIN UserAccount u ON uep.USER_ID=u.USER_ID
				INNER JOIN Priority p ON uep.PRIORITY_ID=p.PRIORITY_ID
				WHERE u.NotCounted=0 AND ENHANCEMENT_ID=e.ID),0)
			 FOR XML AUTO) AS AvgRating,
	s.CanRank AS CanRankStatus,
	(SELECT * FROM Release WHERE EXISTS(SELECT * FROM EnhancementRelease WHERE Release.RELEASE_ID = RELEASE_ID AND ENHANCEMENT_ID=e.ID)
		ORDER BY ReleaseName
		FOR XML AUTO, ROOT('Releases')) AS Releases,
	(SELECT * FROM Module WHERE EXISTS(SELECT * FROM EnhancementModule WHERE Module.MODULE_ID = MODULE_ID AND ENHANCEMENT_ID=e.ID)
		ORDER BY ModuleName
		FOR XML AUTO, ROOT('Modules')) AS Modules,
	(SELECT * FROM Keyword WHERE EXISTS(SELECT * FROM EnhancementKeyword WHERE Keyword.KEYWORD_ID = KEYWORD_ID AND ENHANCEMENT_ID=e.ID)
		ORDER BY Keyword
		FOR XML AUTO, ROOT('Keywords')) AS Keywords,
	(SELECT TOP 1 p.* FROM Priority p WHERE p.PRIORITY_ID=e.SYS_PRIORITY FOR XML AUTO) AS SysPriority,
	(SELECT TOP 1 p.* FROM Priority p
		WHERE EXISTS(SELECT * FROM UserEnhancementPriority uep
			WHERE p.PRIORITY_ID=uep.PRIORITY_ID
				AND uep.ENHANCEMENT_ID=e.ID
				AND uep.[USER_ID]=@USER_ID)
		OR p.Weight=0
		ORDER BY CASE WHEN p.Weight=0 THEN 1 ELSE 0 END
	FOR XML AUTO) AS UserPriority,
	(SELECT ID, Title FROM Enhancement WHERE EXISTS(SELECT * FROM EnhancementSeeAlso WHERE Enhancement.ID = SEE_ALSO_ID AND ENHANCEMENT_ID=e.ID)
		ORDER BY Title
		FOR XML AUTO, ROOT('SeeAlsos')) AS SeeAlsos,
	ISNULL('$' + CAST(es.CostLow AS varchar) + ' - $' + CAST(es.CostHigh AS varchar),EstimateCode) AS CostRange
	FROM Enhancement e
	INNER JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID
	INNER JOIN [Status] s
		ON e.SYS_STATUS=s.STATUS_ID
WHERE e.ID=@ENHANCEMENT_ID

IF @UserEmail IS NOT NULL BEGIN
SELECT PRIORITY_ID, PriorityCode, PriorityName, [Weight] FROM Priority ORDER BY [Weight] DESC

EXEC sp_User_Priorities @UserEmail
EXEC sp_User_Cart @UserEmail
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_Enhancement_Detail] TO [web_user_role]
GO
