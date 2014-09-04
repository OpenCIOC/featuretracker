SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_User_Update]
	@OldEmail varchar(60),
	@Email [varchar](60),
	@Member [int],
	@Agency [char](3),
	@OrgName [varchar](150),
	@FirstName [varchar](50),
	@LastName [varchar](50),
	@EmailOnNew bit,
	@EmailOnUpdate bit,
	@PasswordHashRepeat [int],
	@PasswordHashSalt [char](44),
	@PasswordHash [char](44),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: CL
	Checked on: 27-Feb-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@OldEmail

IF @USER_ID IS NULL BEGIN
	SET @Error = 1
	SET @ErrMsg = @OldEmail + ' is not registered.'
END ELSE IF EXISTS(SELECT * FROM UserAccount u WHERE Email=@Email AND u.[USER_ID]<>@USER_ID) BEGIN
	SET @Error = 2
	SET @ErrMsg = @Email + ' is already in use.'
END ELSE IF @Member IS NOT NULL AND NOT EXISTS(SELECT * FROM Member WHERE MEMBER_ID=@Member) BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Member not found for ID: ' + CAST(@Member AS nvarchar)
END ELSE IF @Agency IS NOT NULL AND NOT EXISTS(SELECT * FROM Agency WHERE AgencyCode=@Agency) BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Agency not found for Code: ' + @Agency
END ELSE BEGIN
	UPDATE UserAccount
		SET Email=@Email,
			MEMBER_ID=@Member,
			Agency=@Agency,
			OrgName=@OrgName,
			FirstName=@FirstName,
			LastName=@LastName,
			EmailOnNew=@EmailOnNew,
			EmailOnUpdate=@EmailOnUpdate,
			PasswordHashRepeat=ISNULL(@PasswordHashRepeat,PasswordHashRepeat),
			PasswordHashSalt=ISNULL(@PasswordHashSalt,PasswordHashSalt),
			PasswordHash=ISNULL(@PasswordHash,PasswordHash)
			
	WHERE UserAccount.[USER_ID]=@USER_ID
END


RETURN @Error
SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_User_Update] TO [web_user_role]
GO
