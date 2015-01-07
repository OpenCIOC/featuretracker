SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_ParseVarCharIDList](
	@IdList varchar(max),
	@Separator char(1)
)
RETURNS @ParsedList TABLE (
	[ItemID] varchar(255) COLLATE Latin1_General_CI_AS NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@itemID varchar(255),
		@Pos int

SET @IdList = LTRIM(RTRIM(@IdList)) + @Separator
SET @Pos = CHARINDEX(@Separator,@IdList,1)

IF REPLACE(@IdList,@Separator,'') <> '' BEGIN
	WHILE @Pos > 0 BEGIN
		SET @itemID = LTRIM(RTRIM(LEFT(@IdList,@Pos-1)))
		IF @itemID <> '' BEGIN
			INSERT INTO @ParsedList (ItemID)
			VALUES (@itemID)
		END
		SET @IdList = RIGHT(@IdList, LEN(@IdList)-@Pos)
		SET @Pos = CHARINDEX(@Separator,@IdList,1)
	END
END

RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_ParseVarCharIDList] TO [web_user_role]
GO
