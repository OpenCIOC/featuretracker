SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_User_Form]
	@UserEmail [varchar](60)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: CL
	Checked on: 27-Feb-2013
	Action: NO ACTION REQUIRED
*/

SELECT Email, MEMBER_ID AS Member, Agency, OrgName, FirstName, LastName, EmailOnNew, EmailOnUpdate FROM UserAccount WHERE Email=@UserEmail

SELECT MEMBER_ID, MemberName FROM Member WHERE Inactive=0 ORDER BY MemberName

SELECT AgencyCode, AgencyName FROM Agency WHERE Inactive=0 ORDER BY AgencyName, AgencyCode

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_User_Form] TO [web_user_role]
GO
