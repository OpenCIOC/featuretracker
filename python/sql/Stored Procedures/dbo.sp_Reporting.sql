SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Reporting]
	@UserEmail [varchar](60)
AS
BEGIN
SET NOCOUNT ON

SET ANSI_WARNINGS OFF

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 30-Oct-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@UserEmail

DECLARE @NEUTRAL_PRIORITY smallint
SELECT @NEUTRAL_PRIORITY=PRIORITY_ID FROM Priority WHERE PriorityCode='NEUTRAL'

DECLARE @TotalUsers float
SELECT @TotalUsers = COUNT(*) FROM UserAccount WHERE NotCounted=0;

DECLARE @TotalEnhancements int
SELECT @TotalEnhancements = COUNT(*) FROM Enhancement WHERE SYS_STATUS IN (1,2)

DECLARE @RankingSummaryTable TABLE (
	OverallRank int,
	ID int PRIMARY KEY NOT NULL,
	Title nvarchar(255),
	CIC bit,
	VOL bit,
	TRACKER bit,
	ENHANCEMENT bit,
	[OFFLINE] bit,
	COMMUNITY bit,
	SysPriority int,
	AvgPriority int,
	UserPriority int,
	CostRange varchar(100),
	MemberSummaryWithCIOCPriority int,
	TimesRankedByUserTotal int,
	TimesRankedByMemberTotal int,
	Top30SummaryByUserAvgRank int,
	Top30SummaryByUserOverallRank int,
	Top30SummaryByMemberAvgRank int,
	Top30SummaryByMemberOverallRank int,
	TimesTop30 int,
	CostRank int
)

INSERT INTO @RankingSummaryTable (ID, Title, CIC, VOL, TRACKER, ENHANCEMENT, [OFFLINE], COMMUNITY, SysPriority, AvgPriority, UserPriority, CostRange, MemberSummaryWithCIOCPriority, TimesRankedByUserTotal, TimesRankedByMemberTotal, CostRank)

SELECT e.id, e.Title, 
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='C') THEN 1 ELSE 0 END AS bit) AS CIC,
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='V') THEN 1 ELSE 0 END AS bit) AS VOL,
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='T') THEN 1 ELSE 0 END AS bit) AS TRACKER,
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='E') THEN 1 ELSE 0 END AS bit) AS ENHANCEMENT,
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='O') THEN 1 ELSE 0 END AS bit) AS [OFFLINE],
	CAST(CASE WHEN EXISTS(SELECT * FROM EnhancementModule em WHERE em.ENHANCEMENT_ID=e.ID AND em.MODULE_ID='R') THEN 1 ELSE 0 END AS bit) AS COMMUNITY,
	p.PRIORITY_ID AS SysPriority,
	(SELECT TOP 1 p.PRIORITY_ID FROM Priority p
		WHERE p.Weight=ROUND(
			(SELECT AVG(CAST(p.Weight AS decimal(4,2)))
				FROM UserEnhancementPriority uep
				INNER JOIN UserAccount u ON uep.USER_ID=u.USER_ID
				INNER JOIN Priority p ON uep.PRIORITY_ID=p.PRIORITY_ID
				WHERE u.NotCounted=0 AND ENHANCEMENT_ID=e.ID),0)
			OR p.PRIORITY_ID=@NEUTRAL_PRIORITY
			ORDER BY CASE WHEN p.PRIORITY_ID=@NEUTRAL_PRIORITY THEN 1 ELSE 0 END
		) AS AvgPriority,
	(SELECT TOP 1 p.PRIORITY_ID FROM Priority p
		WHERE EXISTS(SELECT * FROM UserEnhancementPriority uep
			WHERE p.PRIORITY_ID=uep.PRIORITY_ID
				AND uep.ENHANCEMENT_ID=e.ID
				AND uep.[USER_ID]=@USER_ID)
		OR p.PRIORITY_ID=@NEUTRAL_PRIORITY
		ORDER BY CASE WHEN p.PRIORITY_ID=@NEUTRAL_PRIORITY THEN 1 ELSE 0 END
	) AS UserPriority,
	ISNULL('$' + CAST(es.CostLow AS varchar) + ' - $' + CAST(es.CostHigh AS varchar),EstimateCode) AS CostRange,
	RANK() OVER (ORDER BY ISNULL(SUM(uep.Weight/Divisor),0)+p.Weight*2 DESC, SUM(uep.InPriorityOrder/Divisor) ASC) AS OverallRank,
	COUNT(uep.ENHANCEMENT_ID) AS Picked,
	(SELECT COUNT(DISTINCT MEMBER_ID) FROM [UserEnhancementPriority] uep2
			INNER JOIN [UserAccount] u2 ON uep2.USER_ID=u2.USER_ID
			WHERE uep2.ENHANCEMENT_ID=e.ID AND u2.NotCounted=0) AS PickedMember,
	CASE WHEN es.ESTIMATE_ID = 0 THEN 16 ELSE es.ESTIMATE_ID END * 3 - 2 AS CostRank
	FROM Enhancement e
	LEFT JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID
	LEFT JOIN [Priority] p
		ON e.SYS_PRIORITY=p.PRIORITY_ID
	LEFT JOIN (SELECT ep.ENHANCEMENT_ID, ep.InPriorityOrder, p.Weight, 
			(SELECT COUNT(*) FROM [UserEnhancementPriority] uep2
				INNER JOIN [UserAccount] u2 ON uep2.USER_ID=u2.USER_ID AND u.MEMBER_ID=u2.MEMBER_ID AND u.USER_ID<>u2.USER_ID
				WHERE uep2.ENHANCEMENT_ID=ep.ENHANCEMENT_ID AND u2.NotCounted=0) + 1.0 AS Divisor
		FROM [UserEnhancementPriority] ep
		INNER JOIN [UserAccount] u
			ON ep.USER_ID=u.USER_ID
		INNER JOIN [Priority] p
			ON ep.PRIORITY_ID=p.PRIORITY_ID
		WHERE u.NotCounted=0 AND u.MEMBER_ID IS NOT NULL) uep ON uep.ENHANCEMENT_ID=e.ID
WHERE e.SYS_STATUS in (1,2)
GROUP BY e.ID, e.Title, es.CostLow, es.CostHigh, es.EstimateCode, p.Weight, p.PRIORITY_ID, es.ESTIMATE_ID

/* Top 30 Ranking Summary */

UPDATE r
	SET Top30SummaryByUserAvgRank = AvgRank,
		Top30SummaryByUserOverallRank = Top30OverallRank,
		TimesTop30 = ISNULL(Top30ByUser,0)
FROM @RankingSummaryTable r
LEFT JOIN (
SELECT ID, AVG(TopRank) AS AvgRank, RANK() OVER (ORDER BY (30-AVG(TopRank))*((COUNT(*)/@TotalUsers)) DESC) AS Top30OverallRank, COUNT(*) AS Top30ByUser
	FROM Enhancement e
	LEFT JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID
	INNER JOIN (
			SELECT ENHANCEMENT_ID, TopRank FROM UserAccount u
			CROSS APPLY (
				SELECT TOP 30 ENHANCEMENT_ID, RANK() OVER (ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC) AS TopRank
					FROM UserEnhancementPriority uep
				WHERE PRIORITY_ID IN (SELECT PRIORITY_ID FROM Priority WHERE Weight > 0) AND uep.USER_ID=u.USER_ID
					AND EXISTS(SELECT * FROM Enhancement e2 WHERE e2.ID=uep.ENHANCEMENT_ID AND e2.SYS_STATUS in (1,2))
				ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC
			) AS UserTop30
			WHERE u.NotCounted=0
		) uep ON uep.ENHANCEMENT_ID=e.ID
	WHERE e.SYS_STATUS in (1,2)
	GROUP BY ID, Title, CostAvg
) AS UTop30 ON r.ID = UTop30.ID

/* Top 30 Ranking Summary by Membership */

DECLARE @TotalMemberUsers float
SELECT @TotalMemberUsers = COUNT(DISTINCT MEMBER_ID) FROM UserAccount WHERE NotCounted=0 AND MEMBER_ID IS NOT NULL;

DECLARE @tmpRanking TABLE (
	USER_ID int,
	MEMBER_ID int,
	ENHANCEMENT_ID int,
	TopRank int
)

INSERT INTO @tmpRanking
SELECT USER_ID, MEMBER_ID, ENHANCEMENT_ID, TopRank
FROM UserAccount u
CROSS APPLY (
	SELECT TOP 30 ENHANCEMENT_ID, RANK() OVER (ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC) AS TopRank
		FROM UserEnhancementPriority uep
	WHERE PRIORITY_ID IN (SELECT PRIORITY_ID FROM Priority WHERE Weight > 0) AND uep.USER_ID=u.USER_ID
		AND EXISTS(SELECT * FROM Enhancement e2 WHERE e2.SYS_STATUS in (1,2))
	ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC
) AS UserTop30
WHERE NotCounted=0 AND MEMBER_ID IS NOT NULL

UPDATE r
	SET Top30SummaryByMemberAvgRank = AvgRank,
		Top30SummaryByMemberOverallRank = ISNULL(Top30OverallRank,0)
FROM @RankingSummaryTable r
INNER JOIN (
SELECT ID, AVG(AvgMemberRank) AS AvgRank, RANK() OVER (ORDER BY (30-AVG(AvgMemberRank))*((COUNT(*)/@TotalMemberUsers)) DESC) AS Top30OverallRank
	FROM Enhancement e
	LEFT JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID
	INNER JOIN (
			SELECT MEMBER_ID, ENHANCEMENT_ID, AVG(TopRank) AS AvgMemberRank
			FROM @tmpRanking
			GROUP BY MEMBER_ID, ENHANCEMENT_ID
		) uep ON uep.ENHANCEMENT_ID=e.ID
	WHERE e.SYS_STATUS in (1,2)
GROUP BY ID, Title, CostAvg
) AS UTop30 ON r.ID = UTop30.ID

/* Print out Summary */

UPDATE r
SET OverallRank = FinalRank
FROM @RankingSummaryTable r
INNER JOIN (SELECT ID, RANK() OVER (ORDER BY (3*MemberSummaryWithCIOCPriority
													+ ISNULL(Top30SummaryByUserAvgRank,@TotalEnhancements)
													+ ISNULL(Top30SummaryByUserOverallRank,@TotalEnhancements)
													+ ISNULL(Top30SummaryByMemberAvgRank,@TotalEnhancements)
													+ ISNULL(Top30SummaryByMemberOverallRank,@TotalEnhancements)
													+ CostRank
												)/6.0) AS FinalRank
	FROM @RankingSummaryTable) r2 ON r.ID=r2.ID

SELECT PRIORITY_ID, PriorityCode, PriorityName, [Weight] FROM Priority ORDER BY [Weight] DESC

SELECT r.*, UserRanking.UserRank
	FROM @RankingSummaryTable r
	LEFT JOIN (SELECT TOP 100 PERCENT ENHANCEMENT_ID, RANK() OVER (ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC) AS UserRank
						FROM UserEnhancementPriority uep
					WHERE PRIORITY_ID IN (SELECT PRIORITY_ID FROM Priority WHERE Weight > 0) AND uep.USER_ID=@USER_ID
						AND EXISTS(SELECT * FROM Enhancement e2 WHERE e2.ID=uep.ENHANCEMENT_ID AND e2.SYS_STATUS in (1,2))
					ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC
				) AS UserRanking
		ON r.ID=UserRanking.ENHANCEMENT_ID
ORDER BY OverallRank, MemberSummaryWithCIOCPriority

SET NOCOUNT OFF
END


GO
GRANT EXECUTE ON  [dbo].[sp_Reporting] TO [web_user_role]
GO
