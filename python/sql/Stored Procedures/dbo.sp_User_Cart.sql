SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_User_Cart]
	@UserEmail [varchar](60)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 23-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@UserEmail

SELECT	SUM(es.CostLow) AS CostLow,
		SUM(es.CostAvg) AS CostAvg,
		SUM(es.CostHigh) AS CostHigh,
		SUM(CASE WHEN es.CostLow IS NULL THEN 1 ELSE 0 END) AS NotEstimated
	FROM Enhancement e
	INNER JOIN UserEnhancementPriority uep
		ON e.ID=uep.ENHANCEMENT_ID AND uep.[USER_ID]=@USER_ID
	INNER JOIN Priority p
		ON uep.PRIORITY_ID=p.PRIORITY_ID AND p.Weight > 0
	INNER JOIN Estimate es
		ON e.SYS_ESTIMATE=es.ESTIMATE_ID

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_User_Cart] TO [web_user_role]
GO
