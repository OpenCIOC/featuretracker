SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_EnhancementToModule](
	@ENHANCEMENT_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr		nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = ', '
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + ModuleName
	FROM [dbo].[fn_EnhancementToModule_rst](@ENHANCEMENT_ID)

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END
GO
