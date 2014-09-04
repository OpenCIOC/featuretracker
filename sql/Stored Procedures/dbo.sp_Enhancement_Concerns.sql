SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Enhancement_Concerns]
AS
BEGIN
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 22-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT e.ID, e.Title, u.Email, u.OrgName, u.Agency,
			m.MemberName,
			CASE WHEN u.FirstName IS NOT NULL THEN CASE WHEN u.LastName IS NOT NULL THEN u.FirstName + ' ' + u.LastName ELSE u.FirstName END
				WHEN u.LastName IS NOT NULL THEN u.LastName
				ELSE NULL
			END AS UserName
	FROM Enhancement e
	INNER JOIN UserEnhancementPriority uep
		ON e.ID=uep.ENHANCEMENT_ID AND uep.PRIORITY_ID=1
	INNER JOIN UserAccount u
		ON uep.USER_ID=u.USER_ID
	LEFT JOIN Member m
		ON u.MEMBER_ID=m.MEMBER_ID
ORDER BY e.ID DESC

SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON  [dbo].[sp_Enhancement_Concerns] TO [web_user_role]
GO
