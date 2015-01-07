SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Register_Form]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT MEMBER_ID, MemberName FROM Member WHERE Inactive=0 ORDER BY MemberName

SELECT AgencyCode, AgencyName FROM Agency WHERE Inactive=0 ORDER BY AgencyName, AgencyCode

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_Register_Form] TO [web_user_role]
GO
