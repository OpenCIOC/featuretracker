SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Reporting_Member]
AS
BEGIN
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 23-Jul-2012
	Action: NO ACTION REQUIRED
*/

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
	CostAvg decimal(10,2),
	IsCIC bit,
	IsVOL bit,
	IsTracker bit,
	SystemPriority varchar(50),
	MemberSummaryWithCIOCPriority int,
	TimesRankedByUserTotal int,
	TimesRankedByMemberTotal int,
	Top50SummaryByUserAvgRank int,
	Top50SummaryByUserOverallRank int,
	Top50SummaryByMemberAvgRank int,
	Top50SummaryByMemberOverallRank int,
	TimesTop50 int,
	CostRank int
)

INSERT INTO @RankingSummaryTable (ID, Title, IsCIC, IsVOL, IsTracker, CostAvg, SystemPriority, MemberSummaryWithCIOCPriority, TimesRankedByUserTotal, TimesRankedByMemberTotal, CostRank)

SELECT e.id, e.Title, 
	CASE WHEN EXISTS(SELECT * FROM EnhancementModule WHERE ENHANCEMENT_ID=e.ID AND MODULE_ID='C') THEN 1 ELSE 0 END AS IsCIC,
	CASE WHEN EXISTS(SELECT * FROM EnhancementModule WHERE ENHANCEMENT_ID=e.ID AND MODULE_ID='V') THEN 1 ELSE 0 END AS IsVOL,
	CASE WHEN EXISTS(SELECT * FROM EnhancementModule WHERE ENHANCEMENT_ID=e.ID AND MODULE_ID='T') THEN 1 ELSE 0 END AS IsTracker,
	es.CostAvg, p.PriorityName,
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
GROUP BY e.ID, e.Title, es.CostAvg, p.Weight, p.PriorityName, es.ESTIMATE_ID

/* Top 50 Ranking Summary */

UPDATE r
	SET Top50SummaryByUserAvgRank = AvgRank,
		Top50SummaryByUserOverallRank = Top50OverallRank,
		TimesTop50 = Top50ByUser
FROM @RankingSummaryTable r
INNER JOIN (
SELECT ID, AVG(TopRank) AS AvgRank, RANK() OVER (ORDER BY (50-AVG(TopRank))*((COUNT(*)/@TotalUsers)) DESC) AS Top50OverallRank, COUNT(*) AS Top50ByUser
	FROM Enhancement e
	LEFT JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID
	INNER JOIN (
			SELECT ENHANCEMENT_ID, TopRank FROM UserAccount u
			CROSS APPLY (
				SELECT TOP 50 ENHANCEMENT_ID, RANK() OVER (ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC) AS TopRank
					FROM UserEnhancementPriority uep
				WHERE PRIORITY_ID IN (SELECT PRIORITY_ID FROM Priority WHERE Weight > 0) AND uep.USER_ID=u.USER_ID
					AND EXISTS(SELECT * FROM Enhancement e2 WHERE e2.ID=uep.ENHANCEMENT_ID AND e2.SYS_STATUS in (1,2))
				ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC
			) AS UserTop50
			WHERE u.NotCounted=0
		) uep ON uep.ENHANCEMENT_ID=e.ID
	WHERE e.SYS_STATUS in (1,2)
	GROUP BY ID, Title, CostAvg
) AS UTop50 ON r.ID = UTop50.ID

/* Top 50 Ranking Summary by Membership */

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
	SELECT TOP 50 ENHANCEMENT_ID, RANK() OVER (ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC) AS TopRank
		FROM UserEnhancementPriority uep
	WHERE PRIORITY_ID IN (SELECT PRIORITY_ID FROM Priority WHERE Weight > 0) AND uep.USER_ID=u.USER_ID
		AND EXISTS(SELECT * FROM Enhancement e2 WHERE e2.SYS_STATUS in (1,2))
	ORDER BY PRIORITY_ID DESC, InPriorityOrder ASC
) AS UserTop50
WHERE NotCounted=0 AND MEMBER_ID IS NOT NULL

UPDATE r
	SET Top50SummaryByMemberAvgRank = AvgRank,
		Top50SummaryByMemberOverallRank = Top50OverallRank
FROM @RankingSummaryTable r
INNER JOIN (
SELECT ID, AVG(AvgMemberRank) AS AvgRank, RANK() OVER (ORDER BY (50-AVG(AvgMemberRank))*((COUNT(*)/@TotalMemberUsers)) DESC) AS Top50OverallRank
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
) AS UTop50 ON r.ID = UTop50.ID

/* Print out Summary */

UPDATE r
SET OverallRank = FinalRank
FROM @RankingSummaryTable r
INNER JOIN (SELECT ID, RANK() OVER (ORDER BY (3*MemberSummaryWithCIOCPriority
													+ ISNULL(Top50SummaryByUserAvgRank,@TotalEnhancements)
													+ ISNULL(Top50SummaryByUserOverallRank,@TotalEnhancements)
													+ ISNULL(Top50SummaryByMemberAvgRank,@TotalEnhancements)
													+ ISNULL(Top50SummaryByMemberOverallRank,@TotalEnhancements)
													+ CostRank
												)/6.0) AS FinalRank
	FROM @RankingSummaryTable) r2 ON r.ID=r2.ID

SELECT * FROM @RankingSummaryTable
ORDER BY OverallRank, MemberSummaryWithCIOCPriority

/* Registration and Ranking by Membership */

SELECT m.MemberName, COUNT(DISTINCT u.USER_ID) AS UsersRegistered, COUNT(DISTINCT u.ENHANCEMENT_ID) AS UniqueEnhancementsRanked
	FROM (SELECT MEMBER_ID, MemberName FROM Member UNION SELECT 0 AS MEMBER_ID, 'Not Affiliated or Not Specified' AS MemberName) m
	LEFT JOIN (SELECT u1.USER_ID, u1.MEMBER_ID, uep.ENHANCEMENT_ID FROM UserAccount u1
		LEFT JOIN UserEnhancementPriority uep
			ON u1.USER_ID=uep.USER_ID
		LEFT JOIN Enhancement e
			ON uep.ENHANCEMENT_ID=e.ID AND e.SYS_STATUS IN (1,2)
		WHERE NotCounted=0
	) u ON ISNULL(u.MEMBER_ID,0)=m.MEMBER_ID
GROUP BY m.MemberName

SET NOCOUNT OFF
END

GO
