SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Register]
	@Email [varchar](60),
	@Member [int],
	@Agency [char](3),
	@OrgName [varchar](150),
	@FirstName [varchar](50),
	@LastName [varchar](50),
	@PasswordHashRepeat [int],
	@PasswordHashSalt [char](44),
	@PasswordHash [char](44),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Error int
SET @Error = 0

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@Email

IF @USER_ID IS NOT NULL BEGIN
	SET @Error = 2
	SET @ErrMsg = @Email + ' is already registered'
END ELSE IF @Member IS NOT NULL AND NOT EXISTS(SELECT * FROM Member WHERE MEMBER_ID=@Member) BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Member not found for ID: ' + CAST(@Member AS nvarchar)
END ELSE IF @Agency IS NOT NULL AND NOT EXISTS(SELECT * FROM Agency WHERE AgencyCode=@Agency) BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Agency not found for Code: ' + @Agency
END ELSE BEGIN
	INSERT INTO UserAccount (Email, MEMBER_ID, Agency, OrgName, FirstName, LastName, PasswordHashRepeat, PasswordHashSalt, PasswordHash, Inactive) 
		VALUES (@Email, @Member, @Agency, @OrgName, @FirstName, @LastName, @PasswordHashRepeat, @PasswordHashSalt, @PasswordHash, 0)
	SET @USER_ID = SCOPE_IDENTITY()
END


RETURN @Error
SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_Register] TO [web_user_role]
GO
