SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_User_Admin_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: CL
	Checked on: 26-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT Email FROM UserAccount WHERE TechAdmin = 1

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_User_Admin_l] TO [web_user_role]
GO
