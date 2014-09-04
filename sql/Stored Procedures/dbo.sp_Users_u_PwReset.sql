SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_Users_u_PwReset] (
	@Email varchar(50),
	@PasswordHashRepeat int,
	@PasswordHashSalt char(44),
	@PasswordHash char(44)
)
AS BEGIN

SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

UPDATE UserAccount
	SET PasswordHashRepeat = @PasswordHashRepeat,
		PasswordHashSalt = @PasswordHashSalt,
		PasswordHash = @PasswordHash
	WHERE Email=@Email
	
SELECT FirstName, Email
FROM UserAccount u
WHERE u.Email=@Email

RETURN @Error

SET NOCOUNT OFF

END







GO
GRANT EXECUTE ON  [dbo].[sp_Users_u_PwReset] TO [web_user_role]
GO
