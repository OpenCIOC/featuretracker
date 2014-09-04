SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Suggest_List]
AS
BEGIN
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 23-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT s.SUGGEST_ID, s.Suggestion, dbo.fn_DateString(DateSuggested) AS DateSuggested,
		u.Email, u.OrgName,
			CASE WHEN u.FirstName IS NOT NULL THEN CASE WHEN u.LastName IS NOT NULL THEN u.FirstName + ' ' + u.LastName ELSE u.FirstName END
				WHEN u.LastName IS NOT NULL THEN u.LastName
				ELSE NULL
			END AS UserName
	FROM Suggestion s
	INNER JOIN UserAccount u
		ON s.USER_ID=u.USER_ID
ORDER BY s.DateSuggested DESC

SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON  [dbo].[sp_Suggest_List] TO [web_user_role]
GO
