SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_User_l_EnhancementNotifications]
	@DateSince [smalldatetime]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: CL
	Checked on: 22-Jul-2014
	Action: NO ACTION REQUIRED
*/

;WITH records (ID, Title, Created, Modified, IsAdd)
AS (
SELECT ID, Title, CREATED_DATE AS Created, MODIFIED_DATE as Modified, CASE WHEN CREATED_DATE >= @DateSince THEN 1 ELSE 0 END AS IsAdd
FROM Enhancement WHERE MODIFIED_DATE >= @DateSince 
)
SELECT u.USER_ID, u.Email, u.FirstName, u.EmailOnNew, u.EmailOnUpdate, records.*
FROM UserAccount u
CROSS JOIN records 
WHERE (u.EmailOnNew=1 AND records.IsAdd=1) 
	OR (u.EmailOnUpdate=1 AND EXISTS(SELECT * FROM UserEnhancementPriority p WHERE u.USER_ID=p.USER_ID AND records.ID=p.ENHANCEMENT_ID))
ORDER BY u.USER_ID, IsAdd, records.ID
	
	

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_User_l_EnhancementNotifications] TO [web_user_role]
GO
