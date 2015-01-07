SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Suggest_Delete]
	@SUGGEST_ID int,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Error int
SET @Error = 0

IF @SUGGEST_ID IS NULL BEGIN
	SET @Error = 1
	SET @ErrMsg = 'ID is a required parameter.'
END ELSE IF NOT EXISTS(SELECT * FROM Suggestion WHERE SUGGEST_ID = @SUGGEST_ID) BEGIN
	SET @Error = 1
	SET @ErrMsg = 'Suggestion not found.'
END ELSE BEGIN
	DELETE  Suggestion WHERE SUGGEST_ID=@SUGGEST_ID
END


RETURN @Error
SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_Suggest_Delete] TO [web_user_role]
GO
