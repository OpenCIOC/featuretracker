SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Suggest]
	@Email [varchar](60),
	@Suggestion [nvarchar](max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Error int
SET @Error = 0

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@Email

IF @USER_ID IS NULL BEGIN
	SET @Error = 1
	SET @ErrMsg = @Email + ' is not a known user.'
END ELSE IF @Suggestion IS NULL BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Suggestion is a required field.'
END ELSE BEGIN
	INSERT INTO Suggestion ([USER_ID], Suggestion) VALUES (@USER_ID, @Suggestion)
END


RETURN @Error
SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_Suggest] TO [web_user_role]
GO
