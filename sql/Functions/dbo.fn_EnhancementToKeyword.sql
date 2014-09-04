SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_EnhancementToKeyword](
	@ENHANCEMENT_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr		nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = ', '
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + Keyword
	FROM [dbo].[fn_EnhancementToKeyword_rst](@ENHANCEMENT_ID)

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END
GO
